#encoding: utf-8
 EventType.create( :name => "vote", color: "#C7E4C8"){ |c| c.id = 2}.save
 EventType.create( :name => "meeting", color: "#EDD4B6"){ |c| c.id = 1}.save
GroupAction.create(name: "PROPOSAL_VIEW")
GroupAction.create(name: "PROPOSAL")
GroupAction.create(name: "PROPOSAL_PARTECIPATION")
GroupAction.create(name: "CREATE_EVENT")
GroupAction.create(name: "PROPOSAL_DATE")
GroupAction.create(name: "STREAM_POST")
GroupAction.create(name: "REQUEST_ACCEPT")
GroupAction.create(name: "PROPOSAL_VOTE")
GroupAction.create(name: "PROPOSAL_INSERT")
GroupAction.create(name: "DOCUMENT_VIEW")
GroupAction.create(name: "DOCUMENT_MANAGE")
GroupPartecipationRequestStatus.create( :description => "Inoltrata" ){ |c| c.id = 1}.save
GroupPartecipationRequestStatus.create( :description => "In votazione" ){ |c| c.id = 2}.save
GroupPartecipationRequestStatus.create( :description => "Accettata" ){ |c| c.id = 3}.save
GroupPartecipationRequestStatus.create( :description => "Negata" ){ |c| c.id = 4}.save
nc6 = NotificationCategory.create(seq: 1, short: "MYPROP")
NotificationType.create( :name => "new_contributes_mine", :notification_category_id => nc6.id ){ |c| c.id = 5}.save
NotificationType.create( :name => "change_status_mine", :notification_category_id => nc6.id ){ |c| c.id = 6}.save
NotificationType.create( :name => "new_valutation_mine", :notification_category_id => nc6.id ){ |c| c.id = 20}.save
NotificationType.create( :name => "available_author", :notification_category_id => nc6.id ){ |c| c.id = 22}.save
NotificationType.create( :name => "author_accepted", :notification_category_id => nc6.id ){ |c| c.id = 23}.save
NotificationType.create( :name => "unintegrated_contribute", :notification_category_id => nc6.id ){ |c| c.id = 25}.save
NotificationType.create( :name => "new_comments_mine", :notification_category_id => nc6.id ){ |c| c.id = 27}.save
nc7 = NotificationCategory.create(seq: 2, short: "PROP")
NotificationType.create( :name => "new_contributes", :notification_category_id => nc7.id ){ |c| c.id = 1}.save
NotificationType.create( :name => "text_update", :notification_category_id => nc7.id ){ |c| c.id = 2}.save
NotificationType.create( :name => "change_status", :notification_category_id => nc7.id ){ |c| c.id = 4}.save
NotificationType.create( :name => "new_valutation", :notification_category_id => nc7.id ){ |c| c.id = 21}.save
NotificationType.create( :name => "new_authors", :notification_category_id => nc7.id ){ |c| c.id = 24}.save
NotificationType.create( :name => "new_comments", :notification_category_id => nc7.id ){ |c| c.id = 28}.save
NotificationType.create( :name => "contribute_update", :notification_category_id => nc7.id ){ |c| c.id = 29}.save
nc8 = NotificationCategory.create(seq: 3, short: "NEWPROP")
NotificationType.create( :name => "new_public_proposals", :notification_category_id => nc8.id ){ |c| c.id = 3}.save
NotificationType.create( :name => "new_proposals", :notification_category_id => nc8.id ){ |c| c.id = 10}.save
nc9 = NotificationCategory.create(seq: 4, short: "NEWEVENT")
NotificationType.create( :name => "new_public_events", :notification_category_id => nc9.id ){ |c| c.id = 13}.save
NotificationType.create( :name => "new_events", :notification_category_id => nc9.id ){ |c| c.id = 14}.save
nc10 = NotificationCategory.create(seq: 5, short: "GROUPS")
NotificationType.create( :name => "new_posts_group_follow", :notification_category_id => nc10.id ){ |c| c.id = 8}.save
NotificationType.create( :name => "new_posts_group", :notification_category_id => nc10.id ){ |c| c.id = 9}.save
NotificationType.create( :name => "new_partecipation_request", :notification_category_id => nc10.id ){ |c| c.id = 12}.save
NotificationType.create( :name => "new_posts_user_follow", :notification_category_id => nc10.id ){ |c| c.id = 15}.save
NotificationType.create( :name => "new_blog_comment", :notification_category_id => nc10.id ){ |c| c.id = 26}.save
ProposalCategory.create(:name => "no_category", seq: 20 ){ |c| c.id = 5 }.save
ProposalCategory.create(:name => "education", seq: 9 ){ |c| c.id = 7 }.save
ProposalCategory.create(:name => "health", seq: 6 ){ |c| c.id = 8 }.save
ProposalCategory.create(:name => "information", seq: 11 ){ |c| c.id = 9 }.save
ProposalCategory.create(:name => "commerce", seq: 7 ){ |c| c.id = 10 }.save
ProposalCategory.create(:name => "work", seq: 8 ){ |c| c.id = 11 }.save
ProposalCategory.create(:name => "security", seq: 14 ){ |c| c.id = 12 }.save
ProposalCategory.create(:name => "world", seq: 13 ){ |c| c.id = 13 }.save
ProposalCategory.create(:name => "minorities", seq: 15 ){ |c| c.id = 14 }.save
ProposalCategory.create(:name => "ethics", seq: 16 ){ |c| c.id = 15 }.save
ProposalCategory.create(:name => "sexuality", seq: 17 ){ |c| c.id = 16 }.save
ProposalCategory.create(:name => "culture", seq: 10 ){ |c| c.id = 17 }.save
ProposalCategory.create(:name => "entertainment", seq: 18 ){ |c| c.id = 18 }.save
ProposalCategory.create(:name => "organization", seq: 19 ){ |c| c.id = 19 }.save
ProposalCategory.create(:name => "agricolture", seq: 1 ){ |c| c.id = 20 }.save
ProposalCategory.create(:name => "territory", seq: 2 ){ |c| c.id = 21 }.save
ProposalCategory.create(:name => "mobility", seq: 3 ){ |c| c.id = 22 }.save
ProposalCategory.create(:name => "energy", seq: 4 ){ |c| c.id = 23 }.save
ProposalCategory.create(:name => "industry", seq: 5 ){ |c| c.id = 24 }.save
ProposalCategory.create(:name => "democracy", seq: 12 ){ |c| c.id = 25 }.save
ProposalState.create( :description => "in valutazione" ){ |c| c.id = 1 }.save
ProposalState.create( :description => "in attesa di data" ){ |c| c.id = 2 }.save
ProposalState.create( :description => "in attesa" ){ |c| c.id = 3 }.save
ProposalState.create( :description => "in votazione" ){ |c| c.id = 4 }.save
ProposalState.create( :description => "respinta" ){ |c| c.id = 5 }.save
ProposalState.create( :description => "accettata" ){ |c| c.id = 6 }.save
ProposalState.create( :description => "revisione e feedback" ){ |c| c.id = 7 }.save
ProposalState.create( :description => "abbandonata" ){ |c| c.id = 8 }.save
ProposalType.create( :active => "true", :name => "SIMPLE", color: "#F0EEA4" ){ |c| c.id = 9 }.save
ProposalType.create( :active => "true", :name => "STANDARD", color: "#C5F6EF" ){ |c| c.id = 1 }.save
ProposalType.create( :active => "true", :name => "RULE_BOOK", color: "#F5C5F2" ){ |c| c.id = 3 }.save
ProposalType.create( :active => "true", :name => "PRESS", color: "#E4E4E4" ){ |c| c.id = 4 }.save
ProposalType.create( :active => "true", :name => "EVENT", color: "#C9D1DE" ){ |c| c.id = 5 }.save
ProposalType.create( :active => "true", :name => "ESTIMATE", color: "#C7E4C8" ){ |c| c.id = 6 }.save
ProposalType.create( :active => "true", :name => "AGENDA", color: "#EDD4B6" ){ |c| c.id = 7 }.save
ProposalType.create( :active => "true", :name => "CANDIDATES", color: "#F0B5AD" ){ |c| c.id = 8 }.save
ProposalType.create( :active => "false", :name => "POLL", color: "#F0EEA4" ){ |c| c.id = 2 }.save
RankingType.create( :description => "I agree" ){ |c| c.id = 1 }.save
RankingType.create( :description => "I don't know / I do not understand" ){ |c| c.id = 2 }.save
RankingType.create( :description => "I ​​disagree" ){ |c| c.id = 3 }.save
tut1 = Tutorial.create( :action => "show", :controller => "home", :name => "Welcome Tutorial")
Step.create( :tutorial_id => tut1.id, :index => 0, :title => "Messaggio di benvenuto", :content => "", :required => "false", :fragment => "welcome")
Step.create( :tutorial_id => tut1.id, :index => 1, :title => "Confini geografici di interesse", :content => "", :required => "false", :fragment => "interest_borders")
Step.create( :tutorial_id => tut1.id, :index => 2, :title => "Scegli i gruppi", :content => "", :required => "false", :fragment => "choose_follow")
Step.create( :tutorial_id => tut1.id, :index => 3, :title => "Prima proposta", :content => "", :required => "false", :fragment => "first_proposal")
tut2 = Tutorial.create( :action => "new", :controller => "proposals", :name => "First Proposal")
Step.create( :tutorial_id => tut2.id, :index => 0, :title => "Breve spiegazione", :content => "", :required => "false", :fragment => "proposals_new")
tut3 = Tutorial.create( :action => "show", :controller => "proposals", :name => "Rank Bar")
Step.create( :tutorial_id => tut3.id, :index => 0, :title => "L'anonimato nella discussione", :content => "", :required => "false", :fragment => "proposals_show")
tut5 = Tutorial.create( :action => "index", :controller => "proposals", :name => "Open Space")
Step.create( :tutorial_id => tut5.id, :index => 0, :title => "The Open Space and the proposals list", :content => "", :required => "false", :fragment => "proposals_index")
tut6 = Tutorial.create( :action => "show", :controller => "users", :name => "Setting Tutorial - Personal Info")
Step.create( :tutorial_id => tut6.id, :index => 0, :title => "Settings", :content => "", :required => "false", :fragment => "users_show")
tut7 = Tutorial.create( :action => "alarm_preferences", :controller => "users", :name => "Setting Tutorial - Alarm Preferences")
Step.create( :tutorial_id => tut7.id, :index => 0, :title => "Alarm Preferences", :content => "", :required => "false", :fragment => "users_alarm_preferences")
tut8 = Tutorial.create( :action => "border_preferences", :controller => "users", :name => "Setting Tutorial - Border Preferences")
Step.create( :tutorial_id => tut8.id, :index => 0, :title => "Border Preferences", :content => "", :required => "false", :fragment => "users_border_preferences")
tut9 = Tutorial.create( :action => "privacy_preferences", :controller => "users", :name => "Setting Tutorial - Privacy Preferences")
Step.create( :tutorial_id => tut9.id, :index => 0, :title => "Privacy Preferences", :content => "", :required => "false", :fragment => "users_privacy_preferences")
tut10 = Tutorial.create( :action => "statistics", :controller => "users", :name => "Statistics - Personal Info")
Step.create( :tutorial_id => tut10.id, :index => 0, :title => "Statistics", :content => "", :required => "false", :fragment => "users_statistics")
tut11 = Tutorial.create( :action => "edit", :controller => "groups", :name => "Nuovo menu Impostazioni")
Step.create( :tutorial_id => tut11.id, :index => 0, :title => "Il nuovo MENU Impostazioni", :content => "", :required => "false", :fragment => "groups_edit")
UserType.create( description: "Administrator", :short_name => "admin" ){ |c| c.id = 1}.save
UserType.create( description: "Moderator", :short_name => "mod" ){ |c| c.id = 2}.save
UserType.create( description: "Authenticated User", :short_name => "authuser" ){ |c| c.id = 3}.save
UserType.create( description: "User", :short_name => "user" ){ |c| c.id = 4}.save
UserType.create( description: "Certified", :short_name => "certified" ){ |c| c.id = 5}.save
Quorum.create(name: "1 giorno", percentage: nil, minutes: 1440, good_score: 50, bad_score: 50, vote_percentage: 0, vote_minutes: nil, vote_good_score: 50, t_percentage: "s", t_minutes: "s", t_good_score: "s", t_vote_percentage: "s", t_vote_minutes: "f", t_vote_good_score: "s", public: true, seq: 1)
Quorum.create(name: "3 giorni", percentage: nil, minutes: 4320, good_score: 50, bad_score: 50, vote_percentage: 0, vote_minutes: nil, vote_good_score: 50, t_percentage: "s", t_minutes: "s", t_good_score: "s", t_vote_percentage: "s", t_vote_minutes: "f", t_vote_good_score: "s", public: true, seq: 2)
Quorum.create(name: "7 giorni", percentage: nil, minutes: 10080, good_score: 50, bad_score: 50, vote_percentage: 0, vote_minutes: nil, vote_good_score: 50, t_percentage: "s", t_minutes: "s", t_good_score: "s", t_vote_percentage: "s", t_vote_minutes: "f", t_vote_good_score: "s", public: true, seq: 3)
Quorum.create(name: "15 giorni", percentage: nil, minutes: 21600, good_score: 50, bad_score: 50, vote_percentage: 0, vote_minutes: nil, vote_good_score: 50, t_percentage: "s", t_minutes: "s", t_good_score: "s", t_vote_percentage: "s", t_vote_minutes: "f", t_vote_good_score: "s", public: true, seq: 4)
Quorum.create(name: "30 giorni", percentage: nil, minutes: 43200, good_score: 50, bad_score: 50, vote_percentage: 0, vote_minutes: nil, vote_good_score: 50, t_percentage: "s", t_minutes: "s", t_good_score: "s", t_vote_percentage: "s", t_vote_minutes: "f", t_vote_good_score: "s", public: true, seq: 5)
PartecipationRole.create(:name => "amministratore", :description => "Amministratore"){ |c| c.id = 2 }.save
VoteType.create( :short => "favorable"){ |c| c.id = 1 }.save
VoteType.create( :short => "neutral"){ |c| c.id = 2 }.save
VoteType.create( :short => "dissenting"){ |c| c.id = 3 }.save
ProposalVotationType.create( :short_name => "STANDARD", description: "Standard"){ |c| c.id = 1 }.save
ProposalVotationType.create( :short_name => "PREFERENCE", description: "Preference"){ |c| c.id = 2 }.save
ProposalVotationType.create( :short_name => "SCHULZE", description: "Schulze"){ |c| c.id = 3 }.save
Configuration.create(name: "democracy", value: 1)
Configuration.create(name: "default_user_type", value: 1)
Configuration.create(name: "groups_active", value: 1)
Configuration.create(name: "open_space_calendar", value: 1)
Configuration.create(name: "open_space_proposals", value: 1)
Configuration.create(name: "blog", value: 1)
Configuration.create(name: "phases_active", value: 1)
Configuration.create(name: "socialnetwork_active", value: 1)
Configuration.create(name: "elections_active", value: 1)
Configuration.create(name: "invites_active", value: 1)
Configuration.create(name: "user_messages", value: 1)
Configuration.create(name: "groups_calendar", value: 1)
Configuration.create(name: "proposal_support", value: 1)
Configuration.create(name: "documents_active", value: 1)
Configuration.create(name: "proposal_categories", value: 1)
Configuration.create(name: "folksonomy", value: 1)
Configuration.create(name: "rotp", value: 1)
Configuration.create(name: "group_areas", value: 1)
Configuration.create(name: "recaptcha", value: 1)
SysCurrency.create(description: "EUR")
SysCurrency.create(description: "CHF")
SysCurrency.create(description: "$")
SysLocale.create(key: "it-IT", host: "www.airesis.it", territory_type: "Stato", territory_id: "1")
SysLocale.create(key: "en", host: "www.airesis.eu", territory_type: "Continente", territory_id: "1")
SysLocale.create(key: "en-US", host: "www.airesis.us", territory_type: "Continente", territory_id: "2")
SysLocale.create(key: "fr", host: "www.airesis.eu", territory_type: "Stato", territory_id: "18", lang: "fr")
SysLocale.create(key: "es-ES", host: "www.airesis.eu", territory_type: "Stato", territory_id: "47", lang: "es-ES")
SysLocale.create(key: "pt-PT", host: "www.airesis.eu", territory_type: "Stato", territory_id: "41", lang: "pt-PT")
SysLocale.create(key: "de", host: "www.airesis.eu", territory_type: "Stato", territory_id: "19", lang: "de")
SysLocale.create(key: "pt-BR", host: "www.airesis.us", territory_type: "Stato", territory_id: "54", lang: "pt-BR")
SysLocale.create(key: "es-EC", host: "www.airesis.us", territory_type: "Stato", territory_id: "53", lang: "es-EC")
SysLocale.create(key: "zh", host: "www.airesis.cn", territory_type: "Stato", territory_id: "91")
SysLocale.create(key: "ro-RO", host: "www.airesis.eu", territory_type: "Stato", territory_id: "42", lang: "ro-RO")
SysLocale.create(key: "es-CL", host: "www.airesis.us", territory_type: "Stato", territory_id: "90", lang: "es-CL")
SysMovementType.create(description: "Entrata")
SysMovementType.create(description: "Uscita")
