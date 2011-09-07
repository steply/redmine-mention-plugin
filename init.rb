require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'journal_hook'
end

Redmine::Plugin.register :redmine_mention_plugin do
  name 'Redmine Mention Plugin'
  author 'Steply'
  description 'Add user to watcher list after mentioning him/her (e.g. @john) in issue note'
  version '0.1'
  url 'http://github.com/steply/redmine-mention-plugin'
  author_url 'http://steply.com'
end
