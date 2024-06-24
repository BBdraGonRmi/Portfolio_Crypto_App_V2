class TransactionsController < ApplicationController

  # index / show / new / edit / create / update / destroy
  before_action :set_transaction, only: [:edit, :update, :show, :destroy]
  before_action :require_user
  before_action :require_same_user, only: [:edit, :update, :destroy, :show]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.all
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user
    if @transaction.save
      flash[:success] = "Transaction added!"
      redirect_to transaction_path(@transaction)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    if @transaction.update(transaction_params)
      flash[:success] = "Transaction updated!"
      redirect_to transaction_path(@transaction)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy!
    flash[:danger] = "Transaction deleted!"
    redirect_to transactions_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:datetime_of_transaction, :operation, :symbol, :amount, :price, :net_value, :fees, :total_value, :user_id, :wallet_id)
    end

    def require_same_user
      if current_user != @transaction.user
        flash[:danger] = "You don't have the rights for this!"
        redirect_to root_path
      end
    end
end
