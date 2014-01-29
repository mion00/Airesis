Airesis::Application.routes.draw do

  resources :sys_payment_notifications

  resources :sys_features

  mount Ckeditor::Engine => '/ckeditor'

  match 'home', :to => 'home#show'
  get '/edemocracy', to: redirect('/e-democracy')
  localized do
    match '/partecipa' => 'home#engage'
    match '/chisiamo' => 'home#whowe'
  end
  match '/roadmap' => 'home#roadmap'
  match '/bugtracking' => 'home#bugtracking'
  match '/videoguide' => 'home#videoguide'
  match '/e-democracy' => 'home#whatis'
  match '/eparticipation' => 'home#intro'
  localized do
    match '/story' => 'home#story'
  end
  match '/sostienici' => 'home#helpus'
  match '/donations' => 'home#donations'
  match '/press' => 'home#press'
  match '/privacy' => 'home#privacy'
  match '/terms' => 'home#terms'
  match '/send_feedback' => 'home#feedback'
  match '/statistics' => 'home#statistics'
  match '/movements' => 'home#movements'
  match '/school' => 'home#school'
  match '/municipality' => 'home#municipality'

  resources :user_likes

  resources :proposal_nicknames

  #common routes both for main app and subdomains


  resources :quorums do
    collection do
      get :dates
      get :help
    end
  end

  resources :best_quorums, :controller => 'quorums'
  resources :old_quorums, :controller => 'quorums'

  localized do
    resources :proposals do
      collection do
        get :endless_index
        get :similar
        get :tab_list
      end
      resources :proposal_comments do
        member do
          put :rankup
          put :ranknil
          put :rankdown
          get :show_all_replies
          put :unintegrate
          get :history
        end
        collection do
          post :mark_noise
          get :list
          get :left_list
          get :edit_list
          post :report
          get :noise
          get :manage_noise
        end
      end

      resources :proposal_histories
      resources :proposal_lives
      resources :proposal_supports
      resources :proposal_presentations

      resources :blocked_proposal_alerts do
        collection do
          post :block
          post :unlock
        end
      end

      member do
        get :rankup
        get :rankdown
        get :statistics
        put :set_votation_date
        post :available_author
        get :available_authors_list
        put :add_authors
        get :vote_results
        post :close_debate
        put :regenerate
        get :geocode
        get :facebook_share
        post :facebook_send_message
      end
      end
    end

  resources :proposal_categories

  resources :blogs do

    resources :blog_posts do
      #match :tag, :on => :member
      match :drafts, :on => :collection

      resources :blog_comments
    end
    match '/:year/:month' => 'blogs#by_year_and_month', :as=> :posts_by_year_and_month, on: :member
  end

  resources :announcements do
    member do
      post :hide
    end
  end

  resources :sys_movements

  resources :tutorial_progresses

  resources :tutorials do
    resources :steps do
      member do
        get :complete
      end
    end
    resources :tutorial_assignees
  end

  resources :alerts do
    member do
      get :check_alert
    end

    collection do
      get :polling
      get :proposal
      get :read_alerts
      post :check_all
    end
  end

  resources :group_invitations do
    collection do
      get :accept
      get :reject
      get :anymore
    end
  end

  resources :interest_borders
  resources :comunes

  match 'elfinder' => 'elfinder#elfinder'

  #match '/users/auth/facebook/setup', :to => 'users/facebook#setup'

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks", :registrations => "registrations", :passwords => "passwords", :confirmations => 'confirmations'} do
    get '/users/sign_in', :to => 'devise/sessions#new'
    get '/users/sign_out', :to => 'devise/sessions#destroy'
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end


  resources :users do
    collection do
      get :confirm_credentials
      get :alarm_preferences #preferenze allarmi utente
      get :border_preferences #preferenze confini di interesse utente
      post :set_interest_borders #cambia i confini di interesse
      post :join_accounts
      get :privacy_preferences
      get :statistics
      post :change_show_tooltips
      post :change_show_urls
      post :change_receive_messages
      post :change_rotp_enabled
      post :change_locale
      post :change_time_zone
    end

    member do
      get :show_message
      post :send_message
      post :update_image
    end

    resources :authentications
  end

  resources :notifications do
    collection do
      post :change_notification_block
      post :change_email_notification_block
      post :change_email_block
    end
  end

  resources :partecipation_roles do
    collection do
      post :change_group_permission
      post :change_user_permission
      post :change_default_role
    end
  end

  resources :blog_posts


  resources :tags

  match '/tags/:text', :to => 'tags#show', :as => 'tag'

  match '/votation/', :to => 'votations#show'
  match '/votation/vote', :to => 'votations#vote'
  match '/votation/vote_schulze', :to => 'votations#vote_schulze'
  resources :votations

  #specific routes for subdomains
  constraints Subdomain do
    match '', to: 'groups#show'

    match '/edit', to: 'groups#edit'
    match '/update', to: 'groups#update'

    resources :elections
    resources :candidates

    resources :quorums do
      member do
        post :change_status
      end
    end


    resources :best_quorums, :controller => 'quorums'
    resources :old_quorums, :controller => 'quorums'

    resources :documents do
      collection do
        get :view
      end
    end


    resources :events do
      resources :meeting_partecipations

      resources :event_comments do
        member do
          post :like
        end
      end
      member do
        post :move
        post :resize
      end
      collection do
        get :list
      end
    end


    resources :group_areas do
      collection do
        put :change
        get :manage
      end

      resources :area_roles do
        collection do
          put :change
          put :change_permissions
        end
      end
    end

    resources :group_partecipations do
      collection do
        post :send_email
        post :destroy_all
      end
    end

    resources :search_partecipants

    resources :forums, controller: 'frm/forums', :only => [:index, :show] do
      resources :topics, controller: 'frm/topics' do
        member do
          get :subscribe
          get :unsubscribe
        end
      end


      resources :topics, controller: 'frm/topics', :only => [:new, :create, :index, :show, :destroy] do
        resources :posts, controller: 'frm/posts'
      end


    end

    namespace :frm do
      get 'forums/:forum_id/moderation', :to => "moderation#index", :as => :forum_moderator_tools
      # For mass moderation of posts
      put 'forums/:forum_id/moderate/posts', :to => "moderation#posts", :as => :forum_moderate_posts
      # Moderation of a single topic
      put 'forums/:forum_id/topics/:topic_id/moderate', :to => "moderation#topic", :as => :moderate_forum_topic
      resources :categories, :only => [:index, :show]
      namespace :admin do
        root :to => "base#index"
        resources :groups, as: 'frm_groups' do
          resources :members do
            collection do
              post :add
            end
          end
        end

        resources :forums do
          resources :moderators
        end

        resources :categories
        resources :topics do
          member do
            put :toggle_hide
            put :toggle_lock
            put :toggle_pin
          end
        end
      end
    end

    get '/:action', controller: 'groups'
    put '/:action', controller: 'groups'
    post '/:action', controller: 'groups'

  end

  #routes available only on main site
  constraints NoSubdomain do

    root :to => 'home#index'

    #match ':controller/:action/:id'
    resources :certifications, only: [:index, :create, :destroy]
    resources :user_sensitives do
      member do
        get :document
      end
    end

    resources :proposal_categories do
      get :index, scope: :collection
    end


    resources :events do
      resources :meeting_partecipations

      resources :event_comments do
        member do
          post :like
        end
      end

      member do
        post :move
        post :resize
      end
      collection do
        get :list
      end
    end

    localized do
      resources :groups do
        member do
          get :ask_for_partecipation
          get :ask_for_follow
          put :partecipation_request_confirm
          put :partecipation_request_decline
          get :edit_events
          get :new_event
          post :create_event
          get :edit_permissions
          get :edit_proposals
          post :change_default_anonima
          post :change_default_visible_outside
          post :change_advanced_options
          post :change_default_secret_vote
          get :reload_storage_size
          put :enable_areas
          put :remove_post
          get :permissions_list
        end

        collection do
          post :ask_for_multiple_follow
          get :autocomplete
        end


        resources :forums, controller: 'frm/forums', :only => [:index, :show] do
          resources :topics, controller: 'frm/topics' do
            member do
              get :subscribe
              get :unsubscribe
            end
          end


          resources :topics, controller: 'frm/topics', :only => [:new, :create, :index, :show, :destroy] do
            resources :posts, controller: 'frm/posts'
          end


        end

        namespace :frm do
          get 'forums/:forum_id/moderation', :to => "moderation#index", :as => :forum_moderator_tools
          # For mass moderation of posts
          put 'forums/:forum_id/moderate/posts', :to => "moderation#posts", :as => :forum_moderate_posts
          # Moderation of a single topic
          put 'forums/:forum_id/topics/:topic_id/moderate', :to => "moderation#topic", :as => :moderate_forum_topic
          resources :categories, :only => [:index, :show]
          namespace :admin do
            root :to => "base#index"
            resources :groups, as: 'frm_groups' do
              resources :members do
                collection do
                  post :add
                end
              end
            end

            resources :forums do
              resources :moderators
            end

            resources :categories
            resources :topics do
              member do
                put :toggle_hide
                put :toggle_lock
                put :toggle_pin
              end
            end
          end
        end

        get 'users/autocomplete', :to => "users#autocomplete", :as => "user_autocomplete"

        resources :events do
          resources :meeting_partecipations

          member do
            post :move
            post :resize
          end
          collection do
            get :list
          end
        end

        resources :elections

        resources :candidates

        resources :group_partecipations do
          collection do
            post :send_email
            post :destroy_all
          end
        end

        resources :search_partecipants


        resources :proposals do
          collection do
            get :search
          end
          member do
            post :close_debate
            put :regenerate
            get :geocode
          end
        end


        resources :quorums do
          member do
            post :change_status
          end
        end


        resources :best_quorums, :controller => 'quorums'
        resources :old_quorums, :controller => 'quorums'

        resources :documents do
          collection do
            get :view
          end
        end

        resources :group_areas do
          collection do
            put :change
            get :manage
          end

          resources :area_roles do
            collection do
              put :change
              put :change_permissions
            end
          end
        end

        resources :blog_posts do
          #match :tag, :on => :member
          match :drafts, :on => :collection
          resources :blog_comments
        end
      end
    end

    resources :documents do
      collection do
        get :view
        get :download
      end
      member do
      end
    end



    resources :elections do
      member do
        get :vote_page
        post :vote
        get :calculate_results
      end
    end

    match ':controller/:action/:id'

    match ':controller/:action/:id.:format'



    admin_required = lambda do |request|
      request.env['warden'].authenticate? and request.env['warden'].user.admin?
    end

    moderator_required = lambda do |request|
      request.env['warden'].authenticate? and request.env['warden'].user.moderator?
    end

    constraints moderator_required do
      match ':controller/:action/'
      match 'moderator_panel', :to => 'moderator#show', :as => 'moderator/panel'
    end


    constraints admin_required do
      mount Resque::Server, :at => "/resque_admin/"
      mount Maktoub::Engine => "/maktoub/"
      match ':controller/:action/'
      resources :admin
      match 'admin_panel', :to => 'admin#show', :as => 'admin/panel'
    end


    resources :tokens, :only => [:create, :destroy]

    get '/:id' => 'groups#show'

  end

end
