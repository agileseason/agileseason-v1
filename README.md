Agile Season
============

> Agile board for github issues with metrics

[![Join the chat at https://gitter.im/agileseason/agileseason](https://badges.gitter.im/agileseason/agileseason.svg)](https://gitter.im/agileseason/agileseason?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Code Climate](https://codeclimate.com/github/agileseason/agileseason/badges/gpa.svg)](https://codeclimate.com/github/agileseason/agileseason)
[![Codeship Status for agileseason/agileseason](https://codeship.com/projects/79aa4950-4c53-0132-44ef-36f51938a765/status)](https://codeship.com/projects/47044)

## [DEPRECATED] Not maintained
The first version of **Agile Season** reach End-Of-Life **October 15th**.
If you are interested in this project you can try [Agile Season II](https://agileseason.com) based on GitHub Apps without access to code.

---

Look at the our development board for example - [agileseason.com](https://agileseason.com/boards/agileseason/agileseason)

![Board example](https://github.com/agileseason/agileseason/blob/master/doc/help/board_features/board_example.png)

## Features List

- [x] Agile board with custom columns
- [x] [Drag and drop issues between columns](https://github.com/agileseason/agileseason/wiki/Ready-to-next-stage-button)
- [x] Search and sort issues
- [x] Attach images by drag & drop
- [x] [Auto-assign and auto-close issue](https://github.com/agileseason/agileseason/wiki/Auto-closing-issues)
- [x] [Issues due dates](https://github.com/agileseason/agileseason/wiki/Issues-due-dates)
- [x] [Board markdown export](https://github.com/agileseason/agileseason/wiki/Board-Markdown-Export)
- [x] [Public read-only access](https://github.com/agileseason/agileseason/wiki/Public-read-only-access)
- [x] [Keyboard shortcuts](https://github.com/agileseason/agileseason/wiki/Keyboard-shortcuts)
- [ ] Roadmap with milestones

### Kanban

- [x] WIP limit on columns
- [x] [Cumulative Flow Diagram](https://github.com/agileseason/agileseason/wiki/Kanban-metrics#cumulative-flow-diagram)
- [x] [Control Chart](https://github.com/agileseason/agileseason/wiki/Kanban-metrics#control-chart)
- [x] Cycle Time Diagram
- [x] [Age of Issues](https://agileseason.com/docs/age)

## Troubleshooting

1. [Why can't I see my Github organization's repositories?](https://github.com/agileseason/agileseason/wiki/Troubleshooting#why-cant-i-see-my-github-organizations-repositories)

## Development

### Getting Started
1. Clone this repository `git clone git@github.com:agileseason/agileseason.git ~/PROJECTS_DIR/agileseason`
2. Install [pow](http://pow.cx/) and set up app `cd ~/.pow && ln -s ~/PROJECTS_DIR/agileseason`
3. Create databases:

   ```
    $ psql -d postgres
    postgres=# create user agileseason_development with password 'agileseason';
    postgres=# alter user agileseason_development createdb;
    postgres=# create user agileseason_test with password 'agileseason';
    postgres=# alter user agileseason_test createdb;
    $ rails db:create
    $ rails db:migrate
    ```
4. `$ npm install --save react react-dom babelify babel-preset-react`
5. `$ browserify -t [ babelify --presets [ react ] ] app/assets/javascripts/react/main.js -o  app/assets/javascripts/react/bundle.js`
6. Run Sidekiq `bundle exec sidekiq`
7. You will now have Agile Season running on `http://agileseason.dev`.

### Dependencies
  1. `psql`
  1. `node` and `browserify`

### Backup
1. Add to `~/.zshrc` rows `export BACKUP_DROPBOX_API_KEY='...'` and `export BACKUP_DROPBOX_API_SECRET='...'`
1. Manually run `cd ~/PROJECTS_DIR/agileseason/backup` and `RAILS_ENV='...' bundle exec backup perform --trigger rails_database --config-file ./config.rb`
1. Restore from a backup in production `psql -U agileseason_production -d agileseason_production -f PostgreSQL.sql -h 127.0.0.1`

## License

[The MIT License (MIT)](https://github.com/agileseason/agileseason/blob/master/LICENSE)
