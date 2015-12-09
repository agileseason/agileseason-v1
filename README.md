Agile Season
============
[ ![Codeship Status for agileseason/agileseason](https://codeship.com/projects/79aa4950-4c53-0132-44ef-36f51938a765/status)](https://codeship.com/projects/47044)
[![Code Climate](https://codeclimate.com/github/agileseason/agileseason/badges/gpa.svg)](https://codeclimate.com/github/agileseason/agileseason)
[![Test Coverage](https://codeclimate.com/github/agileseason/agileseason/badges/coverage.svg)](https://codeclimate.com/github/agileseason/agileseason)
[![Dependency Status](https://gemnasium.com/agileseason/agileseason.svg)](https://gemnasium.com/agileseason/agileseason)

Agile board for github issues with metrics

Look at the our development board for example - [agileseason.com](https://agileseason.com/boards/agileseason/agileseason)

![Board example](https://github.com/agileseason/agileseason/blob/master/doc/help/board_features/board_example.png)

## Features List

- [x] Agile board with custom columns
- [x] [Drag and drop issues between columns](https://github.com/agileseason/agileseason/wiki/Board-features)
- [x] Search and sort issues
- [x] Attach images by drag & drop
- [x] [Board markdown export](https://github.com/agileseason/agileseason/wiki/Board-features#board-markdown-export)
- [ ] Roadmap
- [ ] Timeline
- [ ] Bus factor

### Kanban

- [x] WIP limit on columns

#### Graphs

- [x] [Cumulative Flow Diagram](https://github.com/agileseason/agileseason/wiki/Kanban-metrics#cumulative-flow-diagram)
- [x] [Control Chart](https://github.com/agileseason/agileseason/wiki/Kanban-metrics#control-chart)
- [x] Cycle Time Diagram
- [ ] Forecast Duration

### Scrum [MVP 2]

- [ ] Sprints

#### Graphs

- [ ] Velocity Chart
- [ ] Burndown Chart
- [ ] Forecast Duration

## Development

### Getting Started
1. Clone this repository `git clone git@github.com:agileseason/agileseason.git ~/PROJECTS_DIR/agileseason`
2. Install [pow](http://pow.cx/) and set up app `cd ~/.pow && ln -s ~/PROJECTS_DIR/agileseason`
3. Create databases:
  1. `$ psql -d postgres`
  2. `postgres=# create user agileseason_development with password 'agileseason';`
  3. `postgres=# alter user agileseason_development createdb;`
  4. `postgres=# create user agileseason_test with password 'agileseason';`
  5. `postgres=# alter user agileseason_test createdb;`
  6. `$ rake db:create`
  7. `$ rake db:migrate`
4. Run Sidekiq `bundle exec sidekiq`
5. You will now have Agile Season running on `http://agileseason.dev`.

### Backup
1. Add to `~/.zshrc` rows `export BACKUP_DROPBOX_API_KEY='...'` and `export BACKUP_DROPBOX_API_SECRET='...'`
1. Manually run `cd ~/PROJECTS_DIR/agileseason/backup` and `RAILS_ENV='...' bundle exec backup perform --trigger rails_database --config-file ./config.rb`
1. Restore from a backup in production `psql -U agileseason_production -d agileseason_production -f PostgreSQL.sql -h 127.0.0.1`

## License

The MIT License (MIT)

Copyright (c) 2014 Alexander Kalinichev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
