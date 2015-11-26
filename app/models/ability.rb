# TODO Need specs
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
    comments_ability
  end

  private

  def board_ability
    can :manage, Board do |board|
      board.owner?(@user)
    end

    can [:read, :update], Board do |board|
      can?(:manage, board) || Boards::DetectRepo.call(user: @user, board: board).present?
    end

    can :read, Board, &:public?
    can :update_issue, BoardBag, &:has_write_permission?
  end

  def comments_ability
    can :comments, BoardBag do |board_bag|
      can?(:update, board_bag.board) || (!@user.guest? && board_bag.has_read_permission?)
    end

    can :read_comments, BoardBag, &:public?

    can :manage_comments, Board, Object do |board, comment|
      can?(:update, board) ||
        (board.public? && comment.try(:user).try(:login) == @user.github_username)
    end
  end
end
