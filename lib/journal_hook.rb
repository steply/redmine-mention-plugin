require_dependency 'issue'
require_dependency 'watcher'

module Mention
  module JournalHook
    def self.included(base)
      base.send(:after_create) do |journal|
        if journal.journalized.is_a?(Issue) && journal.notes.present?
          issue = journal.journalized
          # TODO Should ignore email
          mentioned_users = journal.notes.scan(/\@\w+/)
          mentioned_users.each do |mentioned_user|
            username = mentioned_user[1..-1] # Remove the heading '@'
            if user = User.find_by_login(username)
              Watcher.create(:watchable => issue, :user => user)
            end
          end
        end
      end
    end
  end
end

Journal.send(:include, Mention::JournalHook) unless Journal.included_modules.include? Mention::JournalHook
