class BasepointsController < ApplicationController
  
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :edit_basic_info, :update_basic_info]
  
  def index
    @basepoints = Basepoint.all
  end

  def new
    @basepoint = Basepoint.new # ベースポイントオブジェクトを生成し、インスタンス変数に代入します。
  end
  
  def create
    @basepoint = Basepoint.new(basepoint_params)
    if @basepoint.save
      flash[:success] = '拠点情報を追加しました。'
      redirect_to basepoints_path
    else
      render :new
    end
  end
  
  def destroy
    Basepoint.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to basepoints_path
  end
  
  def edit_basic_info
    @basepoint = Basepoint.find(params[:id])
  end
  
  def update
   @basepoint = Basepoint.find(params[:id])
   if @basepoint.update_attributes(basic_info_params)
    flash[:success] = "拠点情報を更新しました。"
    redirect_to basepoints_path  
   else
    render 'edit_basic_info'
   end
  end
  
  
  
  private

    def basepoint_params
      params.require(:basepoint).permit(:name, :number, :attendtype)
    end
    
    def basic_info_params
     params.require(:basepoint).permit(:name, :number, :attendtype)
    end

    # beforeアクション

    # ログイン済みユーザーか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
     # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin?
    end
    
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end