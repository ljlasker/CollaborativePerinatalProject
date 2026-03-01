/* codebook.js — DataTables initialization for CPP Codebook Browser */

$(document).ready(function () {

  /* --- Badge renderer --- */
  function renderType(data) {
    var cls = 'badge-' + (data || 'blank').toLowerCase();
    return '<span class="badge ' + cls + '">' + (data || '') + '</span>';
  }

  /* --- Truncate long text --- */
  function truncate(data, maxLen) {
    if (!data) return '';
    if (data.length <= maxLen) return data;
    return data.substring(0, maxLen) + '&hellip;';
  }

  /* --- Format expanded child row --- */
  function formatChild(d) {
    var html = '<dl class="child-row">';
    html += '<dt>Column Position</dt><dd>' + d.col_from;
    if (d.col_to && d.col_to !== d.col_from) html += '&ndash;' + d.col_to;
    html += '</dd>';
    html += '<dt>Description</dt><dd>' + (d.description || '&mdash;') + '</dd>';
    if (d.codes) {
      html += '<dt>Value Codes</dt><dd>' + d.codes + '</dd>';
    }
    if (d.missing_codes) {
      html += '<dt>Missing Codes</dt><dd>' + d.missing_codes + '</dd>';
    }
    html += '</dl>';
    return html;
  }

  /* --- Populate filter dropdowns --- */
  var sections = {};
  var types = {};
  CODEBOOK_DATA.forEach(function (row) {
    if (row.section) sections[row.section] = true;
    if (row.type) types[row.type] = true;
  });

  var secSelect = $('#section-filter');
  Object.keys(sections).sort().forEach(function (s) {
    secSelect.append('<option value="' + s + '">' + s + '</option>');
  });

  var typeSelect = $('#type-filter');
  Object.keys(types).sort().forEach(function (t) {
    typeSelect.append('<option value="' + t + '">' + t + '</option>');
  });

  /* --- Initialize DataTable --- */
  var table = $('#codebook-table').DataTable({
    data: CODEBOOK_DATA,
    columns: [
      {
        data: 'varname',
        className: 'font-mono',
        title: 'Variable'
      },
      {
        data: 'label',
        title: 'Label'
      },
      {
        data: 'type',
        title: 'Type',
        render: function (data) { return renderType(data); }
      },
      {
        data: 'section',
        title: 'Section'
      },
      {
        data: 'description',
        title: 'Description',
        className: 'truncated',
        render: function (data, type) {
          if (type === 'display') return truncate(data, 80);
          return data;  /* full text for search/filter */
        }
      }
    ],
    pageLength: 25,
    lengthMenu: [10, 25, 50, 100],
    order: [],  /* preserve original order (by column position) */
    language: {
      search: 'Search:',
      info: 'Showing _START_&ndash;_END_ of _TOTAL_ variables',
      lengthMenu: 'Show _MENU_ per page'
    },
    autoWidth: false
  });

  /* --- Section filter --- */
  secSelect.on('change', function () {
    var val = this.value;
    table.column(3).search(val ? '^' + val.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$' : '', true, false).draw();
  });

  /* --- Type filter --- */
  typeSelect.on('change', function () {
    var val = this.value;
    table.column(2).search(val ? '^' + val.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$' : '', true, false).draw();
  });

  /* --- Row click to expand/collapse --- */
  $('#codebook-table tbody').on('click', 'tr', function () {
    var row = table.row(this);
    if (row.child.isShown()) {
      row.child.hide();
      $(this).removeClass('shown');
    } else {
      row.child(formatChild(row.data())).show();
      $(this).addClass('shown');
    }
  });

});
