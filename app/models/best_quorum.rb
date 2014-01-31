#encoding: utf-8
class BestQuorum < Quorum

  validates :minutes, numericality: {only_integer: true, greater_than_or_equal_to: 5}
  attr_accessor :vote_days_m, :vote_hours_m, :vote_minutes_m

  before_save :populate_vote

  before_update :populate_vote!

  after_find :populate_accessor

  def valutations
    (read_attribute :valutations) || 1
  end

  def populate_accessor
    super
    self.vote_minutes_m = self.vote_minutes
    if self.vote_minutes_m
      if self.vote_minutes_m > 59
        self.vote_hours_m = self.vote_minutes_m/60
        self.vote_minutes_m = self.vote_minutes_m%60
        if self.vote_hours_m > 23
          self.vote_days_m = self.vote_hours_m/24
          self.vote_hours_m = self.vote_hours_m%24
        end
      end
    end
  end


  #se i minuti non vengono definiti direttamente (come in caso di copia) allora calcolali dai dati di input
  def populate_vote
    unless self.vote_minutes
      self.vote_minutes = self.vote_minutes_m.to_i + (self.vote_hours_m.to_i * 60) + (self.vote_days_m.to_i * 24 * 60)
      self.vote_minutes = nil if (self.vote_minutes == 0)
    end
    self.bad_score = self.good_score
  end

  def populate_vote!
    self.vote_minutes = self.vote_minutes_m.to_i + (self.vote_hours_m.to_i * 60) + (self.vote_days_m.to_i * 24 * 60)
    self.vote_minutes = nil if (self.vote_minutes == 0)
  end

  def or?
    raise Exception
  end

  def and?
    raise Exception
  end

  def time_fixed?
    true #new quora are all time fixed
  end

  def vote_time_set?
    self.t_vote_minutes == 's'
  end

  def vote_time_free?
    self.t_vote_minutes == 'f'
  end

  #text to show in the stop cursor of rank bar
  def end_desc
    I18n.l self.ends_at
  end


  #short description of time left to show in the rank bar and proposals list
  def time_left
    amount = self.ends_at - Time.now #left in seconds
    if amount > 0
      left = I18n.t('time.left.seconds', count: amount.to_i)
      if amount >= 60 #if more or equal than 60 seconds left give me minutes
        amount_min = amount/60
        left = I18n.t('time.left.minutes', count: amount_min.to_i)
        if amount_min >= 60 #if more or equal than 60 minutes left give me hours
          amount_hour = amount_min/60
          left = I18n.t('time.left.hours', count: amount_hour.to_i)
          if amount_hour > 24 #if more than 24 hours left give me days
            amount_days = amount_hour/24
            left = I18n.t('time.left.days', count: amount_days.to_i)
          end
        end
      end
      left.upcase
    else
      "IN STALLO" #todo:i18n
    end
  end

  #show the total time of votation
  def vote_time
    case self.t_vote_minutes
      when 'f'
        'free' #TODO:I18n
      when 's'
        min = self.vote_minutes if self.vote_minutes

        if min && min > 0
          if min > 59
            hours = min/60
            min = min%60
            if hours > 23
              days = hours/24
              hours = hours%24
              min = 0 if hours != 0
              if days > 30
                months = days/30
                days = days%30
                min = 0
              end
            end
          end
          ar = []
          ar << I18n.t('time.left.months', count: months) if (months && months > 0)
          ar << I18n.t('time.left.days', count: days) if (days && days > 0)
          ar << I18n.t('time.left.hours', count: hours) if (hours && hours > 0)
          ar << I18n.t('time.left.minutes', count: min) if (min && min > 0)
          retstr = ar.join(" #{I18n.t('words.and')} ")
        else
          retstr = nil
        end
        retstr
      when 'r'
        'ranged'
      else

    end

  end

  def check_phase(force_end)
    proposal = self.proposal

    timepassed = Time.now > self.ends_at
    vpassed = (!self.valutations || proposal.valutations >= self.valutations)
    #if both parameters were defined

    passed = timepassed || force_end #maybe we want to force the end of the proposal

    if passed #if we have to move one
      if proposal.rank >= self.good_score && vpassed #and we passed the debate quorum
        if proposal.vote_defined #the user already choosed the votation period! that's great, we can just sit along the river waiting for it to begin
          proposal.proposal_state_id = ProposalState::WAIT
          #automatically create
          if proposal.vote_event_id
            @event = Event.find(proposal.vote_event_id)
          else
            event_p = {
                event_type_id: EventType::VOTAZIONE,
                title: "Votazione #{proposal.title}",
                starttime: proposal.vote_starts_at,
                endtime: proposal.vote_ends_at,
                description: "Votazione #{proposal.title}"
            }
            if proposal.private?
              @event = proposal.presentation_groups.first.events.create!(event_p)
            else
              @event = Event.create!(event_p)
            end

            #fai partire il timer per far scadere la proposta
            Resque.enqueue_at(@event.starttime, EventsWorker, {:action => EventsWorker::STARTVOTATION, :event_id => @event.id})
            Resque.enqueue_at(@event.endtime, EventsWorker, {:action => EventsWorker::ENDVOTATION, :event_id => @event.id})
          end
          proposal.vote_period = @event
        else
          proposal.proposal_state_id = ProposalState::WAIT_DATE #we passed the debate, we are now waiting for someone to choose the vote date
          proposal.private? ?
              notify_proposal_ready_for_vote(proposal, proposal.presentation_groups.first) :
              notify_proposal_ready_for_vote(proposal)
        end

        #remove the timer if is still there
        if self.minutes
          Resque.remove_delayed(ProposalsWorker, {:action => ProposalsWorker::ENDTIME, :proposal_id => proposal.id})
        end
      else
        abandon(proposal)

        proposal.private? ?
            notify_proposal_abandoned(proposal, proposal.presentation_groups.first) :
            notify_proposal_abandoned(proposal)

        #remove the timer if is still there
        if self.minutes
          Resque.remove_delayed(ProposalsWorker, {:action => ProposalsWorker::ENDTIME, :proposal_id => proposal.id})
        end
      end

      proposal.save
      proposal.reload
    end
  end


  def close_vote_phase
    proposal = self.proposal
    if proposal.is_schulze?
      vote_data_schulze = proposal.schulze_votes
      Proposal.transaction do
        votesstring = ""; #stringa da passare alla libreria schulze_vote per calcolare il punteggio
        vote_data_schulze.each do |vote|
          #in ogni riga inserisco la mappa del voto ed eventualmente il numero se più di un utente ha espresso la stessa preferenza
          vote.count > 1 ? votesstring += "#{vote.count}=#{vote.preferences}\n" : votesstring += "#{vote.preferences}\n"
        end
        num_solutions = proposal.solutions.count
        vs = SchulzeBasic.do votesstring, num_solutions
        solutions_sorted = proposal.solutions.sort { |a, b| a.id <=> b.id } #ordino le soluzioni secondo l'id crescente (così come vengono restituiti dalla libreria)
        solutions_sorted.each_with_index do |c, i|
          c.schulze_score = vs.ranks[i].to_i
          c.save!
        end
        votes = proposal.schulze_votes.sum(:count)
        if votes >= self.vote_valutations
          proposal.proposal_state_id = ProposalState::ACCEPTED
        else
          proposal.proposal_state_id = ProposalState::REJECTED
        end
      end #fine transazione
    else
      vote_data = proposal.vote
      positive = vote_data.positive
      negative = vote_data.negative
      neutral = vote_data.neutral
      votes = positive + negative + neutral
      if ((positive+negative) > 0) && ((positive / (positive+negative)) > (self.vote_good_score.to_f / 100)) && (votes >= self.vote_valutations) #se ha avuto più voti positivi allora diventa ACCETTATA
        proposal.proposal_state_id = ProposalState::ACCEPTED
      elsif positive <= negative #se ne ha di più negativi allora diventa RESPINTA
        proposal.proposal_state_id = ProposalState::REJECTED
      end
    end
    proposal.save!
    proposal.private ?
        notify_proposal_voted(proposal, proposal.presentation_groups.first, proposal.presentation_areas.first) :
        notify_proposal_voted(proposal)
  end


  def has_bad_score?
    false #new quora does not have bad score
  end


  def debate_progress
    minimum = [Time.now, self.ends_at].min
    minimum = ((minimum - self.started_at)/60)
    percentagetime = minimum.to_f/self.minutes.to_f
    percentagetime *= 100
    percentagetime
  end

  protected

  def min_partecipants_pop
    count = 1
    if self.percentage
      if self.group
        count = (self.percentage.to_f * 0.01 * self.group.count_proposals_partecipants) #todo group areas
      else
        count = (self.percentage.to_f * 0.001 * User.count)
      end
      [count, 1].max.floor + 1 #we always add +1 in new quora
    else
      1
    end
  end

  def min_vote_partecipants_pop
    count = 1
    if self.vote_percentage
      if self.group
        count = (self.vote_percentage.to_f * 0.01 * self.group.count_voter_partecipants) #todo group areas
      else
        count = (self.vote_percentage.to_f * 0.001 * User.count)
      end
      [count, 1].max.floor + 1 #we always add +1 in new quora
    else
      1
    end
  end

  def explanation_pop
    conditions = []
    ret = ''
    if assigned? #explain a quorum assigned to a proposal
      if self.proposal.abandoned?
        ret = terminated_explanation_pop
      else
        ret = assigned_explanation_pop
      end
    else
      ret = unassigned_explanation_pop #it a non assigned quorum
    end

    ret += "."
    ret.html_safe
  end


  #TODO we need to refactor this part of code but at least now is more clear
  #explain a quorum when assigned to a proposal in it's current state
  def assigned_explanation_pop
    ret = ''
    time = "<b>#{self.time}</b> "
    time +=I18n.t('models.quorum.until_date', date: I18n.l(self.ends_at))
    ret = I18n.translate('models.quorum.time_condition_1', time: time) #display the time left for discussion
    ret += "<br/>"
    participants = I18n.t('models.quorum.participants', count: self.valutations)
    ret += I18n.translate('models.best_quorum.good_score_condition', good_score: self.good_score, participants: participants)
    ret
  end

  #explain a quorum in a proposal that has terminated her life cycle
  def terminated_explanation_pop
    ret = ''
    time = "<b>#{self.time(true)}</b> " #show total time if the quorum is terminated
    time +=I18n.t('models.quorum.until_date', date: I18n.l(self.ends_at))
    ret = I18n.translate('models.quorum.time_condition_1_past', time: time) #display the time left for discussion
    ret += "<br/>"
    participants = I18n.t('models.quorum.participants_past', count: self.valutations)
    ret += I18n.translate('models.best_quorum.good_score_condition_past', good_score: self.good_score, participants: participants)
    ret
  end

  #explain a non assigned quorum
  def unassigned_explanation_pop
    ret = ''
    time = "<b>#{self.time}</b> "
    ret = I18n.translate('models.quorum.time_condition_1', time: time) #display the time left for discussion
    ret += "<br/>"
    participants = I18n.t('models.quorum.participants', count: self.min_partecipants)
    ret += I18n.translate('models.best_quorum.good_score_condition', good_score: self.good_score, participants: participants)
    ret
  end
end
