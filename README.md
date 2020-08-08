## Questions Database Project

Created as part of the App Academy Curriculum.

### Functionality

The purpose of this project was to explore wrapping SQLite3 Data Manipulation Language and Data Query Language into Ruby methods. An `import_db.sql` file is used to seed the database. 5 classes represent the 5 tables in the `questions` database:

- `User`
- `Question`
- `Reply`
- `QuestionFollow`
- `QuestionLike`

There is also a `TableObject` class that `User`, `Question`, and `Reply` inherit from. A small `QuestionsDatabase` class inherits from `SQLite3::Database` and is used to interact with the database.

### Thoughts

I found it very useful seeing how SQL might be wrapped inside Ruby objects. Using heredocs to create SQL commands was pretty straightforward until trying to refactor shared methods into the `TableObject` superclass because of the unknown column names and values (each depending on that class's instance variables.) It was a challenge getting the values I needed for the SQL statement while still sanitizing the input. I hoped to use hash key-value pair syntax, but couldn't understand the right syntax to use. The `#execute(sql, bind_vars = [], *args, &block) ⇒ Object` line and sparse accompanying notes from the [docs](https://www.rubydoc.info/github/luislavena/sqlite3-ruby/SQLite3%2FDatabase:execute) were not helpful enough. I still managed to generalize shared methods by using the `bind_vars` array, but I don't like that this is dependent on the `instance_variables` call returning the variables in the order I expect (they always have, but this seems brittle and less than ideal).

The assignment asked that the `where` method accept an entire string so that the user could call something like `Question.where("title LIKE '%Who%' AND title LIKE '%Arstan Whitebeard%'")`. This seems extremely vulnerable to injection attacks, and, given the work I had just done making sure all the other input was sanitized, I was not willing to add that functionality. I do, however, allow wildcard characters to be included in the values of the key-value pairs: `Question.where(title: '%Who%', title: '%Arstan Whitebeard%')`.

The rspec tests were pretty straightforward to write until trying to test the `create` and `update` methods, which required that I manipulate the database, test it, and return it back to its initial state. I seem to have achieved this with `before` and `after` hooks that open and rollback, respectively, a transaction for a `QuestionsDatabase` instance.

I did not test that the query methods hit the database the correct number of times. I did not see a way to do this and it also didn't seem particularly useful. I also realize that most of my future SQL work will be in Rails, so it is probably overkill to dive too obsessively into obscure testing in plain Ruby.

-Andrew Hayhurst