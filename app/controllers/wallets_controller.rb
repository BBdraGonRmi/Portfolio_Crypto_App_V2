class WalletsController < ApplicationController

  # index / show / new / edit / create / update / destroy
  before_action :set_wallet, only: [:edit, :update, :show, :destroy]
  before_action :require_user
  before_action :require_same_user, only: [:edit, :update, :destroy, :show]

  # GET /wallets or /wallets.json
  def index
    @wallets = Wallet.all
  end

  # GET /wallets/1 or /wallets/1.json
  def show
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
  end

  # GET /wallets/1/edit
  def edit
  end

  # POST /wallets or /wallets.json
  def create
    @wallet = Wallet.new(wallet_params)
    @wallet.user = current_user
    if @wallet.save
      flash[:success] = "Wallet created!"
      redirect_to wallet_path(@wallet)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /wallets/1 or /wallets/1.json
  def update
    if @wallet.update(wallet_params)
      flash[:success] = "Wallet updated!"
      redirect_to wallet_path(@wallet)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /wallets/1 or /wallets/1.json
  def destroy
    @wallet.destroy!
    flash[:danger] = "Wallet deleted!"
    redirect_to wallets_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wallet_params
      params.require(:wallet).permit(:name, :user_id)
    end

    def require_same_user
      if current_user != @wallet.user
        flash[:danger] = "You don't have the rights for this!"
        redirect_to root_path
      end
    end
end
