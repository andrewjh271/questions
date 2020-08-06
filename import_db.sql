PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT,
  user_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE question_follows (
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (question_id) REFERENCES questions (id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT,

  FOREIGN KEY (question_id) REFERENCES questions (id),
  FOREIGN KEY (parent_reply) REFERENCES replies (id),
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions (id),
  FOREIGN KEY (user_id) REFERENCES users (id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Andrew', 'Hayhurst'),
  ('Beth', 'Grimmig'),
  ('Tommy', 'Daugherty'),
  ('Nicole', 'Sauder'),
  ('Andy', 'Watkins'),
  ('Diana', 'Morgan');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('API??', 'What does API stand for?', (SELECT id FROM users WHERE lname = 'Morgan')),
  ('Breakfast', 'What''s for breakfast?', 2),
  ('Giraffes', 'Why are giraffes tall?', 4),
  ('Yesterday', 'Is yesterday always there?', 4),
  ('Snowden', 'Where are the Snowdens of Yesteryear?', 3);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1, 3),
  (2, 5),
  (1, 5),
  (4, 5),
  (4, 3),
  (2, 3),
  (5, 4);

INSERT INTO
  replies (question_id, parent_reply, user_id, body)
VALUES
  (1, NULL, 1, 'Application Porcupine Interstellar'),
  (1, 1, 1, 'Sorry, I meant Application Programming Interface'),
  (2, NULL, 1, 'Pancakes'),
  (3, NULL, 6, 'Giraffes will always be tall'),
  (3, 4, 4, 'Thanks for your input, but that doesn''t really answer my question.'),
  (4, NULL, 5, 'Yesterday is sometimes there.');

INSERT INTO
  question_likes
VALUES
  (3, 1),
  (3, 3),
  (3, 6),
  (2, 5),
  (2, 6);