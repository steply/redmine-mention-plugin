require 'redmine'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require_dependency 'journal_hook'
  end
else
  Dispatcher.to_prepare do
    require_dependency 'journal_hook'
  end
end

Redmine::Plugin.register :redmine_mention_plugin do
  name 'Redmine Mention Plugin'
  author 'Steply'
  description 'Add user to watcher list after mentioning him/her (e.g. @john) in issue note'
  version '0.1'
  url 'http://github.com/steply/redmine-mention-plugin'
  author_url 'http://steply.com'
end
