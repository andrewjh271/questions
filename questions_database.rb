require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.execute("PRAGMA foreign_keys = ON") # enforces foreign key restraint
    self.type_translation = true
    self.results_as_hash = true
  end
end