module GroupsHelper

  def group_url(group, options={})
    if group.certified?
      root_url(:subdomain => group.subdomain)
    else
      options[:subdomain] = false if (defined? request) && (request.subdomain != 'www')
      super
    end
  end

  def edit_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/edit' :
        super
  end

  def change_default_anonima_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/change_default_anonima' :
        super
  end

  def change_default_visible_outside_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/change_default_visible_outside' :
        super
  end

  def change_default_secret_vote_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/change_default_secret_vote' :
        super
  end

  def change_advanced_options_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/change_advanced_options' :
        super
  end

  def partecipation_request_confirm_group_url(group, options={})
    if (group_in_subdomain? group)
      ret = '/partecipation_request_confirm'
      query = options.to_query
      ret += "?#{query}" unless query.empty?
    else
      super
    end
  end

  def partecipation_request_decline_group_url(group, options={})
    if group_in_subdomain? group
      ret = '/partecipation_request_decline'
      query = options.to_query
      ret += "?#{query}" unless query.empty?
    else
      super
    end
  end

  def reload_storage_size_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/reload_storage_size' :
        super
  end

  def edit_permissions_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/edit_permissions' :
        super
  end

  def edit_proposals_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/edit_proposals' :
        super
  end

  def permissions_list_group_path(group, options={})
    (group_in_subdomain? group) ?
        '/permissions_list' :
        super
  end

  def ask_for_partecipation_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/ask_for_partecipation' :
        super
  end

  def enable_areas_group_url(group, options={})
    (group_in_subdomain? group) ?
        '/enable_areas' :
        super
  end


  def group_group_areas_url(group, options={})
    (group_in_subdomain? group) ?
        group_areas_url(options) :
        super
  end


  def group_group_partecipations_url(group, options={})
    (group_in_subdomain? group) ?
        group_partecipations_url(options) :
        super
  end


  def group_candidates_url(group, options={})
    (group_in_subdomain? group) ?
        candidates_url(options) :
        super
  end

  def group_proposals_url(group, options={})
    if group_in_subdomain? group
      proposals_url(options)
    else
      options[:subdomain] = false unless defined? request
      super
    end
  end

  def group_group_areas_url(group, options={})
    if group_in_subdomain? group
      group_areas_url(options)
    else
      options[:subdomain] = false
      super
    end
  end


  def group_proposal_url(group, proposal, options={})
    if group_in_subdomain? group
      proposal_url(proposal, options)
    else
      if group.certified?
        options[:subdomain] = group.subdomain
        proposal_url(proposal, options)
      else
        options[:subdomain] = false unless defined? request #activated for proposal link when you are in subdomain (like in tags page)...i think there is something wrong here...
                                                  #theres an error for mails coming from https cause we do not have a valid certificate and in the mail is missing wwww, let's try like this and....cross fingers
        super
      end
    end
  end

  def group_search_partecipant_url(group, search_partecipant, options={})
    if group_in_subdomain? group
      search_partecipant_url(search_partecipant, options)
    else
      if group.certified?
        options[:subdomain] = group.subdomain
        search_partecipant_url(search_partecipant, options)
      else
        super
      end
    end
  end

  def group_blog_post_url(group, blog_post, options={})
    if group_in_subdomain? group
      blog_post_url(blog_post, options)
    else
      if group.certified?
        options[:subdomain] = group.subdomain
        blog_post_url(blog_post, options)
      else
        super
      end
    end
  end

  def edit_group_proposal_url(group, proposal, option={})
    (group_in_subdomain? group) ?
        edit_proposal_url(proposal) :
        super
  end

  def close_debate_group_proposal_url(group, proposal, options={})
    (group_in_subdomain? group) ?
        close_debate_proposal_url(proposal) :
        super
  end


  def group_events_url(group, options={})
    if group_in_subdomain? group
      events_url
    else
      options[:subdomain] = false
      super
    end
  end

  def group_documents_url(group, options={})
    (group_in_subdomain? group) ?
        documents_url :
        super
  end

  def group_group_partecipation_url(group, group_partecipation, options={})
    if group_in_subdomain? group
      group_partecipation_url(group_partecipation, options)
    else
      if group.certified?
        options[:subdomain] = group.subdomain
        group_partecipation_url(group_partecipation, options)
      else
        options[:subdomain] = false
        super
      end
    end
  end

  def new_group_candidate_url(group, options={})
    (group_in_subdomain? group) ?
        new_candidate_url(options) :
        super
  end


  def new_group_event_url(group, options={})
    (group_in_subdomain? group) ?
        new_event_url(options) :
        super
  end

  def new_group_group_area_url(group, options={})
    (group_in_subdomain? group) ?
        new_group_area_url(options) :
        super
  end

  def new_group_group_area_area_role_url(group, area, options={})
    (group_in_subdomain? group) ?
        new_group_area_area_role_url(area, options) :
        super
  end

  def edit_group_group_area_url(group, options={})
    (group_in_subdomain? group) ?
        edit_group_area_url(options) :
        super
  end

  def edit_group_group_area_area_role_url(group, area, options={})
    (group_in_subdomain? group) ?
        edit_group_area_area_role_url(area, options) :
        super
  end

  def manage_group_group_areas_url(group, options={})
    (group_in_subdomain? group) ?
        manage_group_areas_url(options) :
        super
  end

  def change_group_group_areas_url(group, options={})
    (group_in_subdomain? group) ?
        change_group_areas_url(options) :
        super
  end

  def new_group_best_quorum_url(group, options={})
    (group_in_subdomain? group) ?
        new_quorum_url(options) :
        super
  end

  def edit_group_best_quorum_url(group, options={})
    (group_in_subdomain? group) ?
        edit_quorum_url(options) :
        super
  end


  def change_group_group_area_area_roles_url(group, area, options={})
    (group_in_subdomain? group) ?
        change_group_area_area_roles_url(area, options) :
        super
  end

  def change_permissions_group_group_area_area_roles_url(group, area, options={})
    (group_in_subdomain? group) ?
        change_permissions_group_area_area_roles_url(area, options) :
        super
  end

  #def group_forums_url(group,option={})
  #  forums_url
  #end


  #todo to be moved as soon as possible
  def check_alert_alert_url(alert,options={})
    subdomain = alert.notification.data[:subdomain]
    options[:subdomain] = subdomain if subdomain.to_s != ''
    super
  end


  #forum
  #all routes concerning forums
  #we write them dynamically to avoid writing every single method.
  #that may cause problems but I hope not and sometime WE WILL REWRITE ALSO others
  if Rails.env == 'development'
    names = Airesis::Application.routes.routes.map { |r| r.name }.select { |n| n =~ /(group_frm_|group_forum).*/ }
    names.each do |name|
      self.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
    def #{name}_url(group,*args)
      (group_in_subdomain? group) ?
        #{name.gsub('group_', '')}_url(*args) :
        super
    end if !(defined? #{name})
      END_EVAL
    end
  end

  #forum
  #all routes concerning forums
  #we write them dynamically to avoid writing every single method.
  #that may cause problems but I hope not and sometime WE WILL REWRITE ALSO others
  #Airesis::Application.reload_routes!
  def self.init
    names = Airesis::Application.routes.routes.map { |r| r.name }.select { |n| n =~ /(group_frm_|group_forum).*/ }
    names.each do |name|
      Rails.logger.info "defining: #{name}_url"
      define_method("#{name}_url") do |group, *args|
        (group_in_subdomain? group) ?
            send("#{name.gsub('group_', '')}_url", *args) :
            super(group, *args)
      end
      #self.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
      #def #{name}_url(group,*args)
      #  (group_in_subdomain? group) ?
      #    #{name.gsub('group_', '')}_url(*args) :
      #    super
      #end
      #END_EVAL
    end
  end


  private

  def group_in_subdomain?(group)
    (defined? request) && group.certified && (request.subdomain == group.subdomain)
  end
end
