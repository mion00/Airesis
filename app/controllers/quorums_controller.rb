#encoding: utf-8
class QuorumsController < ApplicationController
  include NotificationHelper

  #load group
  before_filter :load_group, :except => :help
  before_filter :load_quorum, :only => [:edit, :update, :destroy, :dates]

  #security controls
  before_filter :authenticate_user!

  before_filter :check_permissions, :only => [:new,:create,:edit,:update,:destroy,:change_status]

  layout :choose_layout

  def new
    @page_title=  t('pages.groups.edit_quorums.new_quorum.title')
    @quorum = BestQuorum.new({:percentage => 0, :good_score => 20, :vote_percentage => 0, :vote_good_score => 50})
    @partecipants_count = @group.count_proposals_partecipants
    @vote_partecipants_count = @group.count_voter_partecipants
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    begin
      BestQuorum.transaction do
        @quorum = @group.quorums.build(params[:best_quorum])
        @quorum.public = false
        @group.save!
      end

      respond_to do |format|
        flash[:notice] = t('info.quorums.quorum_created')
        format.js
      end

    rescue Exception => e
      respond_to do |format|
        flash[:error] = t('error.quorums.quorum_creation')
        format.js { render :update do |page|
          page.replace_html "flash_messages", :partial => 'layouts/flash', :locals => {:flash => flash}
          page.alert @quorum.errors.full_messages.join(";") if (@quorum && @quorum.errors)
        end
        }
        #format.html { redirect_to edit_permissions_group_path(@quorum) }
      end
    end
  end

  def edit
    @page_title = t('pages.groups.edit_quorums.edit_quorum')
    @partecipants_count = @group.count_proposals_partecipants
    @vote_partecipants_count = @group.count_voter_partecipants
  end


  def update
    Quorum.transaction do
      @quorum.attributes = params[:best_quorum]
      @quorum.save!
    end

    respond_to do |format|
      flash[:notice] = t('info.quorums.quorum_updated')
      format.js
    end

  rescue Exception => e
    respond_to do |format|
      flash[:error] = t('error.quorums.quorum_modification')
      format.js { render :update do |page|
        page.replace_html "flash_messages", :partial => 'layouts/flash', :locals => {:flash => flash}
        page.alert @quorum.errors.full_messages.join(";") if (@quorum && @quorum.errors)
      end
      }
    end
  end


  def destroy
    @quorum = @group.quorums.find_by_id(params[:id])
    @quorum.destroy
    flash[:notice] = t('info.quorums.quorum_deleted')

    respond_to do |format|
      format.js { render :update do |page|
        page.replace_html "flash_messages", :partial => 'layouts/flash', :locals => {:flash => flash}
        page.replace_html "quorum_panel_container", :partial => 'groups/quorums_panel'
      end
      }
    end
  end

  def change_status
    Quorum.transaction do
      quorum = @group.quorums.find_by_id(params[:id])
      if quorum
        if params[:active] == "true" #devo togliere i permessi
          quorum.active = true
          flash[:notice] =t('info.quorums.quorum_activated')
        else #lo disattivo
          quorum.active = false
          flash[:notice] =t('info.quorums.quorum_deactivated')
        end
        quorum.save!
      end
    end

    respond_to do |format|
      format.js { render :update do |page|
        page.replace_html "flash_messages", :partial => 'layouts/flash', :locals => {:flash => flash}
      end
      }
    end
  end


  def help
    if params[:group_id]
      @group = Group.find(params[:group_id])
      @quorums = @group.quorums.active
    else
      @quorums = Quorum.public.active.all
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  #retrieve a list of votation dates compatibles with that quorum
  def dates
    starttime = Time.now + @quorum.minutes.minutes + DEBATE_VOTE_DIFFERENCE
    if @group
      @dates = Event.in_group(@group.id).private.vote_period(starttime).all.collect { |p| ["da #{l p.starttime} a #{l p.endtime}", p.id, {'data-start' => (l p.starttime), 'data-end' => (l p.endtime), 'data-title' => p.title}] } #TODO:I18n
    else
      @dates = Event.public.vote_period(starttime).all.collect { |p| ["da #{l p.starttime} a #{l p.endtime}", p.id] } #TODO:I18n
    end
  end


  private
  def check_permissions
    return  if current_user.admin? || (@group.portavoce.include? current_user)
    flash[:error] = t('unauthorized.default')
    respond_to do |format|
      format.js { render :update do |page|
        page.replace_html "flash_messages", :partial => 'layouts/flash', :locals => {:flash => flash}
      end }
    end
  end

  protected


  def load_quorum
    @quorum = Quorum.find(params[:id])
  end


  def choose_layout
    @group ? "groups" : "open_space"
  end

end
