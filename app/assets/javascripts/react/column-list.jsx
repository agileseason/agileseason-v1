var React = require('react');
var ReactDOM = require('react-dom');

// Title
module.exports = React.createClass({
  getInitialState: function() {
    return {
      title: this.props.title,
      h1: 'block',
      textarea: 'none'
    };
  },
  componentDidUpdate: function() {
    var $textarea = $(this.refs.title)
    if (!$textarea.hasClass('elasticable')) {
      $textarea.addClass('elasticable');
      $textarea.elastic();
    }
    if (this.state.textarea == 'block') {
      $textarea.focus().val('').val(this.state.title);
    }
  },
  handleEditTitleClick: function() {
    var title = this.state.title.trim();
    if (title == '') {
      return;
    }
    if (this.state.h1 == 'block') {
      this.setState({h1: 'none', textarea: 'block'});
    } else {
      this.setState({h1: 'block', textarea: 'none'});
      this.props.onUpdateTitle(title);
    }
  },
  handleTextChange: function(e) {
    this.setState({title: e.target.value});
  },
  handleKeyDown: function(e) {
    if (e.keyCode == 13) {
      this.handleEditTitleClick();
    }
  },
  render: function() {
    return(
      <div className='issue-title'>
        <h1 style={{display: this.state.h1}}>
          <span onClick={this.handleEditTitleClick}>{this.state.title}</span>
          <a href={this.props.url}>#{this.props.number}</a>
          <CurrentDueDate data={this.props.dueDate} />
        </h1>
        <textarea
          ref='title'
          type='text'
          placeholder='Edit title'
          value={this.state.title}
          onChange={this.handleTextChange}
          onBlur={this.handleEditTitleClick}
          onKeyDown={this.handleKeyDown}
          style={{display: this.state.textarea}}
        />
      </div>
    );
  }
});

// ColumnList
module.exports = React.createClass({
  getInitialState: function() {
    return {
      data: this.props.data,
      current: this.props.current
    };
  },
  handleColumnClick: function(e) {
    var columnId = $(e.target).data('column');
    if (columnId == this.state.current) {
      return;
    }
    this.setState({current: columnId});
    this.props.onColumnChange(columnId);
  },
  render: function() {
    var columnNodes = this.state.data.map(function(column) {
      var className = column.id == this.state.current ? 'active' : '';
      return (
        <li className={className} key={column.id}>
          <a href='#' onClick={this.handleColumnClick} data-column={column.id}>{column.name}</a>
        </li>
      );
    }.bind(this));
    return (
      <ul className='column-list'>
        {columnNodes}
      </ul>
    );
  }
});
