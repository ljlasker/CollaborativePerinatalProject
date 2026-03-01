/* codebook.js — DataTables initialization for CPP Codebook Browser */

$(document).ready(function () {

  /* ============================================================
     CPPVAR Codebook Table (1,239 variables)
     ============================================================ */

  function renderType(data) {
    var cls = 'badge-' + (data || 'blank').toLowerCase();
    return '<span class="badge ' + cls + '">' + (data || '') + '</span>';
  }

  function truncate(data, maxLen) {
    if (!data) return '';
    if (data.length <= maxLen) return data;
    return data.substring(0, maxLen) + '&hellip;';
  }

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

  /* Populate CPPVAR filter dropdowns */
  var sections = {}, types = {};
  CODEBOOK_DATA.forEach(function (row) {
    if (row.section) sections[row.section] = true;
    if (row.type) types[row.type] = true;
  });
  Object.keys(sections).sort().forEach(function (s) {
    $('#section-filter').append('<option value="' + s + '">' + s + '</option>');
  });
  Object.keys(types).sort().forEach(function (t) {
    $('#type-filter').append('<option value="' + t + '">' + t + '</option>');
  });

  var cppvarTable = $('#codebook-table').DataTable({
    data: CODEBOOK_DATA,
    columns: [
      { data: 'varname', className: 'font-mono', title: 'Variable' },
      { data: 'label', title: 'Label' },
      { data: 'type', title: 'Type', render: function (data) { return renderType(data); } },
      { data: 'section', title: 'Section' },
      { data: 'description', title: 'Description', className: 'truncated',
        render: function (data, type) {
          if (type === 'display') return truncate(data, 80);
          return data;
        }
      }
    ],
    pageLength: 25,
    lengthMenu: [10, 25, 50, 100],
    order: [],
    language: {
      search: 'Search:',
      info: 'Showing _START_&ndash;_END_ of _TOTAL_ variables',
      lengthMenu: 'Show _MENU_ per page'
    },
    autoWidth: false
  });

  $('#section-filter').on('change', function () {
    var val = this.value;
    cppvarTable.column(3).search(val ? '^' + val.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$' : '', true, false).draw();
  });
  $('#type-filter').on('change', function () {
    var val = this.value;
    cppvarTable.column(2).search(val ? '^' + val.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$' : '', true, false).draw();
  });

  $('#codebook-table tbody').on('click', 'tr', function () {
    var row = cppvarTable.row(this);
    if (row.child.isShown()) {
      row.child.hide();
      $(this).removeClass('shown');
    } else {
      row.child(formatChild(row.data())).show();
      $(this).addClass('shown');
    }
  });

  /* ============================================================
     Unified Manifest Table (4,862 variables)
     ============================================================ */

  function formatManifestChild(d) {
    var html = '<dl class="child-row">';
    html += '<dt>Variable Name</dt><dd><code>' + d.varname + '</code></dd>';
    html += '<dt>Original Name</dt><dd>' + (d.original_name || '&mdash;') + '</dd>';
    html += '<dt>Source</dt><dd>' + d.source + '</dd>';
    html += '<dt>Label</dt><dd>' + (d.label || '&mdash;') + '</dd>';
    html += '<dt>N (non-missing)</dt><dd>' + d.n.toLocaleString() + '</dd>';
    html += '<dt>% Missing</dt><dd>' + d.pct_missing + '%</dd>';
    if (d.is_numeric && d.mean) {
      html += '<dt>Mean</dt><dd>' + d.mean + '</dd>';
      html += '<dt>SD</dt><dd>' + d.sd + '</dd>';
    }
    html += '</dl>';
    return html;
  }

  function formatNum(val) {
    if (!val || val === '') return '&mdash;';
    var n = parseFloat(val);
    if (isNaN(n)) return val;
    if (Math.abs(n) >= 1000) return n.toLocaleString(undefined, {maximumFractionDigits: 1});
    if (Math.abs(n) >= 10) return n.toFixed(1);
    return n.toFixed(2);
  }

  /* Populate source filter */
  var sourceCounts = {};
  MANIFEST_DATA.forEach(function (row) {
    sourceCounts[row.source] = (sourceCounts[row.source] || 0) + 1;
  });
  /* Sort sources by count descending, show top sources */
  var sourceList = Object.keys(sourceCounts).sort(function (a, b) {
    return sourceCounts[b] - sourceCounts[a];
  });
  sourceList.forEach(function (s) {
    $('#source-filter').append('<option value="' + s + '">' + s + ' (' + sourceCounts[s] + ')</option>');
  });

  var manifestTable = $('#manifest-table').DataTable({
    data: MANIFEST_DATA,
    columns: [
      { data: 'varname', className: 'font-mono', title: 'Variable' },
      { data: 'label', title: 'Label', className: 'truncated',
        render: function (data, type) {
          if (type === 'display') return truncate(data, 60);
          return data;
        }
      },
      { data: 'source', title: 'Source' },
      { data: 'n', title: 'N', render: function (data) { return data.toLocaleString(); } },
      { data: 'pct_missing', title: '% Miss',
        render: function (data, type) {
          if (type === 'display') return data.toFixed(1) + '%';
          return data;
        }
      },
      { data: 'mean', title: 'Mean', render: function (data, type) { return type === 'display' ? formatNum(data) : data; } },
      { data: 'sd', title: 'SD', render: function (data, type) { return type === 'display' ? formatNum(data) : data; } }
    ],
    pageLength: 25,
    lengthMenu: [10, 25, 50, 100],
    order: [],
    language: {
      search: 'Search:',
      info: 'Showing _START_&ndash;_END_ of _TOTAL_ variables',
      lengthMenu: 'Show _MENU_ per page'
    },
    autoWidth: false,
    deferRender: true
  });

  $('#source-filter').on('change', function () {
    var val = this.value;
    manifestTable.column(2).search(val ? '^' + val.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$' : '', true, false).draw();
  });

  $('#manifest-table tbody').on('click', 'tr', function () {
    var row = manifestTable.row(this);
    if (row.child.isShown()) {
      row.child.hide();
      $(this).removeClass('shown');
    } else {
      row.child(formatManifestChild(row.data())).show();
      $(this).addClass('shown');
    }
  });

  /* ============================================================
     Tab Switching
     ============================================================ */

  $('.tab-btn').on('click', function () {
    var tab = $(this).data('tab');
    $('.tab-btn').removeClass('active');
    $(this).addClass('active');
    $('.tab-panel').removeClass('active');
    $('#tab-' + tab).addClass('active');
    /* Adjust column widths after tab switch */
    if (tab === 'cppvar') {
      cppvarTable.columns.adjust();
    } else {
      manifestTable.columns.adjust();
    }
  });

});
