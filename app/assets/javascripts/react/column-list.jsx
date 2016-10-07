var React = require('react');
var ReactDOM = require('react-dom');

// ColumnList
module.exports = React.createClass({
  getInitialState: function() {
    return {
      data: this.props.data,
      current: this.props.current
    };
  },
  handleColumnClick: function(e) {
    if (this.props.isReadonly) {
      return;
    }
    var columnId = $(e.target).data('column');
    if (columnId == this.state.current) {
      return;
    }
    this.setState({current: columnId});
    this.props.onColumnChange(columnId);
  },
  componentWillReceiveProps: function(nextProps) {
    this.setState({current: nextProps.current});
  },
  render: function() {
    var columnNodes = this.state.data.map(function(column) {
      var className = column.id == this.state.current ? 'active' : '';
      return (
        <li className={className} key={column.id}>
          <a
            href='#'
            data-turbolinks='false'
            data-column={column.id}
            onClick={this.handleColumnClick}>
            {column.name}
          </a>
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
