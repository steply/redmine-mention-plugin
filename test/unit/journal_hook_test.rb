require File.dirname(__FILE__) + '/../test_helper'

class JournalHookTest < ActiveSupport::TestCase
  fixtures :projects, :trackers, :issues, :issue_statuses, :journals, :journal_details, :users, :members, :member_roles

  def setup
    Issue.first.watchers.destroy_all
  end

  def test_add_mentioned_user_to_watchers_list
    user = users(:users_001)
    assert_not_watching Issue.first, user
    assert_difference("Issue.first.watchers.length", +1) do
      assert Journal.create(:journalized => Issue.first, :user => user, :notes => "@#{user.login} Mention that user")
      assert_watching Issue.first, user
    end
  end

  def test_add_multiple_mentioned_users_to_watchers_list
    user1 = users(:users_001)
    user2 = users(:users_002)
    assert_not_watching Issue.first, user1
    assert_not_watching Issue.first, user2
    assert_difference("Issue.first.watchers.length", +2) do
      assert Journal.create(:journalized => Issue.first, :user => user1, :notes => "@#{user1.login} Mention that user\r\nMention another user to, see @#{user2.login}\r\n")
      assert_watching Issue.first, user1
      assert_watching Issue.first, user2
    end
  end

  def test_ignore_journal_with_empty_note
    assert_no_difference("Issue.first.watchers.length") do
      assert Journal.create(:journalized => Issue.first, :user => User.first, :notes => "")
    end
  end

  def test_ignore_user_that_are_already_in_watchers_list
    user = users(:users_001)
    assert Watcher.create(:user => user, :watchable => Issue.first)
    assert_watching Issue.first, user
    assert_no_difference("Issue.first.watchers.length") do
      assert Journal.create(:journalized => Issue.first, :user => user, :notes => "@#{user.login} Mention that user")
      assert_watching Issue.first, user
    end
  end

  def test_ignore_unknown_user
    assert !User.find_by_login('foo')
    user = users(:users_001)
    assert_not_watching Issue.first, user
    assert_difference("Issue.first.watchers.length", +1) do
      assert Journal.create(:journalized => Issue.first, :user => user, :notes => "@#{user.login} Mention that user\r\nMention unknown user @foo")
      assert_watching Issue.first, user
    end
  end

  def test_safely_ignore_other_at_symbol
    user = users(:users_001)
    assert_not_watching Issue.first, user
    assert_no_difference("Issue.first.watchers.length") do
      assert Journal.create(:journalized => Issue.first, :user => user, :notes => "@@@, @-asdfsf, @")
      # assert Journal.create(:journalized => Issue.first, :user => user, :notes => "test@#{user.login}.com")
    end
  end

  private

  def assert_watching(watchable, user)
    assert watchable.watchers.collect(&:user_id).include?(user.id), "#{user.login} is not watching #{watchable.inspect}"
  end

  def assert_not_watching(watchable, user)
    assert !watchable.watchers.collect(&:user_id).include?(user.id), "#{user.login} is watching #{watchable.inspect}"
  end
end
