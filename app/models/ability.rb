class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    @user = user || User.new
    board_ability
  end

  private

  def board_ability
    can :manage, Board do |board|
      owner?(board)
    end

    can [:read, :update], Board do |board|
      owner?(board) || Boards::DetectRepo.call(user: @user, board: board).present?
    end

    can :read, Board do |board|
      board.public?
    end

    can :update_issue, BoardBag do |board_bag|
      board_bag.has_write_permission?
    end

    can :comments, BoardBag do |board_bag|
      !@user.guest? && board_bag.has_read_permission?
    end

    can :manage_comments, Board, Object do |board, comment|
      can?(:update, board) ||
        (board.public? && comment.try(:user).try(:login) == @user.github_username)
    end
  end

  def owner?(board)
    @user.id == board.user_id
  end
end
