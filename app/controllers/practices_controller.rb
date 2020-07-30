class PracticesController < ApplicationController
  include LogsHelper

  authorize_resource
  before_action :authenticate_user!  
 	before_action :validate_authorization

  # GET /practice
  # GET /practice.json
  
  def validate_authorization
  	authorize! :admin, :practice
  end
  
  def index
    log_controller_call LogAction::VIEW, "View all practices"
    @practices = Practice.all
		@practice = Practice.new
		@users = User.all.map {|user| [user.username, user.id]}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @practice }
    end
  end

  # GET /practices/1
  # GET /practices/1.json
  def show
    log_controller_call LogAction::VIEW, "View practice"
    @practice = Practice.find(params[:id])
    @users = User.all.map {|user| [user.username, user.id]}
    if @practice.nil?
      respond_to do |format|
        format.html { redirect_to practices_path, notice: 'A practice with that identifier could not be found.' }
        format.json { render json: @practice, status: :not_found }
      end
    else
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @practice }
      end
    end
  end
  
  # POST /practices
  # POST /practices.json
  def create
    log_controller_call LogAction::ADD, "Create practice"
  begin
    @practice = Practice.new(name: params[:practice]['name'], organization: params[:practice]['organization'], address: params[:practice]['address'])
    @practice.save
    if @practice.save
      identifier = CDAIdentifier.new(:root => "Organization", :extension => @practice.organization)
      provider = Provider.new(:given_name => @practice.name)
      provider.cda_identifiers << identifier
      #TODO
      # provider.parent = Provider.root
      provider.save
      @practice.provider = provider
      if params[:user] != ''
        user = User.find(params[:user])
        @practice.users << user
        user.save
      end
    end
    respond_to do |format|
      if @practice.save
        format.html { redirect_to practices_path, notice: 'Practice was successfully created.' }
        format.json { render json: @practice, status: :created, location: @practice }
      else
        format.html { redirect_to practices_path }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  rescue Exception => e
    puts "Error creating practice"
    puts e.message
  end
  end

  # PUT /practices
  # PUT /practices.json
  def update
    @practice = Practice.find(params[:id])
    @practice.update_attributes(params[:practice]) unless @practice.nil?

    respond_to do |format|
      if @practice.save
        log_controller_call LogAction::UPDATE, "Update practice"
        format.html { redirect_to practices_path, notice: 'Practice was successfully updated.' }
        format.json { render json: @practice, status: :created, location: @practice }
      else
        log_controller_call LogAction::UPDATE, "Failed to update practice, with errors #{get_errors_for_log(@practice)}"
        format.html { redirect_to practices_path }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def remove_patients
    log_controller_call LogAction::DELETE, "Remove all patients for practice", true
    Record.where(practice_id: params[:id]).delete
    practice = Practice.find(params[:id])
    if practice  
      provider_id = practice.provider_id.to_s  
      CQM::Patient.all.each do |p|        
        pdata = JSON.parse(p.extendedData["provider_performances"]).select{|pid| pid["provider_id"] == provider_id}
        if pdata.present?
          QDM::IndividualResult.where(patient_id:p._id.to_s).delete
          p.delete()
        end
      end
     end
    respond_to do |format|
      format.html { redirect_to :action => :index }
    end
  end
  
  def remove_providers
    log_controller_call LogAction::DELETE, "Remove all providers for practice"
    practice = Practice.find(params[:id])
    Provider.where(parent_id: practice.provider.id).delete
    
    respond_to do |format|
      format.html { redirect_to :action => :index }
    end
  end
  
  # DELETE /practices/1
  # DELETE /practices/1.json
  def destroy
    log_controller_call LogAction::DELETE, "Remove practice"
    @practice = Practice.find(params[:id])
    Record.where(practice_id: @practice.id).delete
    if @practice.provider
      id = @practice.provider.id
      @current_user.teams.each do |tm|
        team.providers.delete(id.to_s)
        team.save!
      end
      @current_user.save!
      @practice.provider.delete
    end
    @practice.destroy

    respond_to do |format|
      format.html { redirect_to :action => :index}
    end
  end
private
def practice_params
  params.require(:practice).permit('name', 'organization', 'address')
end

end

