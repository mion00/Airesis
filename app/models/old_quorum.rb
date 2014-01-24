#encoding: utf-8
class OldQuorum < Quorum
  validate :minutes_or_percentage
  validates :condition, :inclusion => {:in => ['OR', 'AND']}


  def minutes_or_percentage
    if self.days_m.blank? && self.hours_m.blank? && self.minutes_m.blank? && !self.percentage && !self.minutes
      self.errors.add(:minutes, "Devi indicare la durata della proposta o il numero minimo di partecipanti")
    end
  end

  def or?
    self.condition && (self.condition.upcase == 'OR')
  end

  def and?
    self.condition && (self.condition.upcase == 'AND')
  end

  def time_fixed?
    self.minutes && !self.percentage && ((self.good_score == self.bad_score) || !self.bad_score)
  end

  #text to show in the stop cursor of rank bar
  def end_desc
    conds = []
    conds << "#{I18n.l self.ends_at} " if self.ends_at
    conds << " #{I18n.t('pages.proposals.new_rank_bar.valutations', count: self.valutations)}" if self.valutations
    conds.join(or? ? I18n.t('words.or') : I18n.t('words.and'))
  end


  #short description of time left
  def time_left
    ret = []
    if self.ends_at
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
        ret << left.upcase
      end
    end
    if self.valutations
      valutations = self.valutations - self.proposal.valutations
      if valutations > 0
        ret << I18n.t('pages.proposals.new_rank_bar.valutations', count: valutations)
      end
    end
    if ret.size > 0
      ret.join(or? ? " #{I18n.t('words.or').upcase} " : " #{I18n.t('words.and').upcase} ")
    else
      "IN STALLO" #todo:i18n
    end

  end


  def check_phase(force_end)
    proposal = self.proposal
    passed = false
    timepassed = (!self.ends_at || Time.now > self.ends_at)
    vpassed = (!self.valutations || proposal.valutations >= self.valutations)
    #if both parameters were defined
    if self.ends_at && self.valutations
      if self.or?
        passed = (timepassed || vpassed)
      else
        self.and?
        passed = (timepassed && vpassed)
      end
    else #we just need one of two (one will be certainly true)
      passed = (timepassed && vpassed)
    end
    passed = passed || force_end #maybe we want to force the end of the proposal

    if passed #if we have to move one
      if proposal.rank >= self.good_score #and we passed the debate quorum
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
      elsif proposal.rank < self.bad_score #if we have not passed the debate quorum abandon it
        abandon(proposal)

        proposal.private? ?
            notify_proposal_abandoned(proposal, proposal.presentation_groups.first) :
            notify_proposal_abandoned(proposal)

        #remove the timer if is still there
        if self.minutes
          Resque.remove_delayed(ProposalsWorker, {:action => ProposalsWorker::ENDTIME, :proposal_id => proposal.id})
        end
      else #if we are between bad and good score just do nothing...continue the debate

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
        proposal.proposal_state_id = ProposalState::ACCEPTED
      end #fine transazione
    else
      vote_data = proposal.vote
      positive = vote_data.positive
      negative = vote_data.negative
      neutral = vote_data.neutral
      votes = positive + negative + neutral
      if positive > negative #se ha avuto più voti positivi allora diventa ACCETTATA
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
    self.bad_score && (self.bad_score != self.good_score)
  end


  def debate_progress
    percentages = []
    if valutations
      minimum = [self.proposal.valutations, self.valutations].min
      percentagevals = minimum.to_f/self.valutations.to_f
      percentagevals *= 100
      percentages << percentagevals
    end
    if minutes
      minimum = [Time.now, self.ends_at].min
      minimum = ((minimum - self.started_at)/60)
      percentagetime = minimum.to_f/self.minutes.to_f
      percentagetime *= 100
      percentages << percentagetime
    end

    if self.or?
      percentages.max
    else
      percentages.min
    end
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
      [count, 1].max.floor
    else
      nil
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
    if self.time_left? #if the quorum has a minimum time and there is still time remaining
      time = "<b>#{self.time}</b> "
      time +=I18n.t('models.quorum.until_date', date: I18n.l(self.ends_at))

      if self.valutations_left?
        participants = I18n.t('models.quorum.participants', count: self.valutations)
        if self.or?
          ret = I18n.translate('models.quorum.or_condition_1', #display number of required evaluations and time left
                               percentage: self.percentage,
                               time: time,
                               participants_num: participants)
        else #and
          ret = I18n.translate('models.quorum.and_condition_1', #display number of required evaluations and time left
                               percentage: self.percentage,
                               time: time,
                               participants_num: participants)

        end
      else #only time
        ret = I18n.translate('models.quorum.time_condition_1', time: time) #display the time left for discussion
      end
    elsif self.valutations_left? #if the quorum has only valutations left
      participants = I18n.t('models.quorum.participants', count: self.valutations)
      ret = I18n.translate('models.quorum.participants_condition_1',
                           percentage: self.percentage,
                           participants_num: participants) #display only number of required evaluations
    else #stalled

    end
    ret += "<br/>"
    if self.bad_score && (self.bad_score != self.good_score) #if quorum has negative quorum and it is not the same as positive quorum
      ret += I18n.translate('models.quorum.bad_score_explain', good_score: self.good_score, bad_score: self.bad_score)
    else #if quorum has negative quorum and it is the same as positive quorum
      ret += I18n.translate('models.quorum.good_score_condition', good_score: self.good_score)
    end
    ret
  end

  #explain a quorum in a proposal that has temrinated her life cycle
  def terminated_explanation_pop
    ret = ''
    if self.minutes #if the quorum has a minimum time
      time = "<b>#{self.time(true)}</b> " #show total time if the quorum is terminated
      time +=I18n.t('models.quorum.until_date', date: I18n.l(self.ends_at))
      if self.percentage
        participants = I18n.t('models.quorum.participants_past', count: self.valutations)
        if self.or?
          ret = I18n.translate('models.quorum.or_condition_1_past', #display number of required evaluations and time left
                               percentage: self.percentage,
                               time: time,
                               participants_num: participants)
        else #and
          ret = I18n.translate('models.quorum.and_condition_1_past', #display number of required evaluations and time left
                               percentage: self.percentage,
                               time: time,
                               participants_num: participants)
        end
      else #only time
        ret = I18n.translate('models.quorum.time_condition_1_past', time: time) #display the time left for discussion
      end
    else #only valutations
      participants = I18n.t('models.quorum.participants_past', count: self.valutations)
      ret = I18n.translate('models.quorum.participants_condition_1_past',
                           percentage: self.percentage,
                           participants_num: participants) #display only number of required evaluations
    end
    ret += "<br/>"
    if self.bad_score && (self.bad_score != self.good_score) #if quorum has negative quorum and it is not the same as positive quorum
      ret += I18n.translate('models.quorum.bad_score_explain_past', good_score: self.good_score, bad_score: self.bad_score)
    else #if quorum has negative quorum and it is the same as positive quorum
      ret += I18n.translate('models.quorum.good_score_condition_past', good_score: self.good_score)
    end
    ret
  end

  #explain a non assigned quorum
  def unassigned_explanation_pop
    ret = ''
    if self.minutes #if the quorum has a minimum time
      time = "<b>#{self.time}</b> "
      if self.percentage
        participants = I18n.t('models.quorum.participants', count: self.min_partecipants)
        if self.or?
          ret = I18n.translate('models.quorum.or_condition_1', #display number of required evaluations and time left
                               percentage: self.percentage,
                               time: time,
                               participants_num: participants)
        else #and
          ret = I18n.translate('models.quorum.and_condition_1', #display number of required evaluations and time left
                               percentage: self.percentage,
                               time: time,
                               participants_num: participants)
        end
      else #if the quorum has only minimum time of discussion
        ret = I18n.translate('models.quorum.time_condition_1', time: time) #display the time left for discussion
      end
    else #only evaluations
      participants = I18n.t('models.quorum.participants', count: self.min_partecipants)
      ret = I18n.translate('models.quorum.participants_condition_1', participants_num: participants) #display number of required evaluations
    end
    ret += "<br/>"
    if self.bad_score && (self.bad_score != self.good_score) #if quorum has negative quorum and it is not the same as positive quorum
      ret += I18n.translate('models.quorum.bad_score_explain', good_score: self.good_score, bad_score: self.bad_score)
    else #if quorum has negative quorum and it is the same as positive quorum
      ret += I18n.translate('models.quorum.good_score_condition', good_score: self.good_score)
    end
    ret
  end



end
