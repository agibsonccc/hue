## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
import time
from django.template.defaultfilters import timesince
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
from beeswax import models
from beeswax.views import collapse_whitespace
%>

<%namespace name="actionbar" file="actionbar.mako" />
<%namespace name="comps" file="beeswax_components.mako" />
<%namespace name="layout" file="layout.mako" />

${ commonheader(_('My Queries'), app_name, user, '100px') | n,unicode }
${layout.menubar(section='my queries')}

<style>
    .tab-content {
        overflow:visible!important;
    }
</style>

<div class="container-fluid">
  <h1>${_('My Queries')}</h1>

  <%actionbar:render>
    <%def name="actions()">
      <button id="viewBtn" class="btn toolbarBtn" title="${_('View the result of the selected')}" disabled="disabled"><i class="icon-eye-open"></i> ${_('View result')}</button>
      <button id="editBtn" class="btn toolbarBtn" title="${_('Edit the selected query')}" disabled="disabled"><i class="icon-edit"></i> ${_('Edit')}</button>
      <button id="cloneBtn" class="btn toolbarBtn" title="${_('Clone the selected query')}" disabled="disabled"><i class="icon-retweet"></i> ${_('Clone')}</button>
      <button id="historyBtn" class="btn toolbarBtn" title="${_('View the usage history of the selected query')}" disabled="disabled"><i class="icon-tasks"></i> ${_('Usage history')}</button>
      <button id="deleteBtn" class="btn toolbarBtn" title="${_('Delete the selected queries')}" disabled="disabled"><i class="icon-trash"></i>  ${_('Delete')}</button>
    </%def>

    <%def name="creation()">
      <a class="btn" href="${ url(app_name + ':execute_query') }"><i class="icon-plus-sign"></i> ${_('Create New Query')}</a>
    </%def>
  </%actionbar:render>

  <ul class="nav nav-tabs">
    <li class="active"><a href="#recentSavedQueries" data-toggle="tab">${_('Recent Saved Queries')} &nbsp;<span id="recentSavedQueriesFilterCnt" class="badge badge-info"></span></a></li>
    <li><a href="#recentRunQueries" data-toggle="tab">${_('Recent Run Queries')}  &nbsp;<span id="recentRunQueriesFilterCnt" class="badge badge-info"></span></a></li>
  </ul>

  <div class="tab-content">
    <div class="active tab-pane" id="recentSavedQueries">
      <table id="recentSavedQueriesTable" class="table table-striped table-condensed datatables">
        <thead>
          <tr>
            <th width="1%"><div class="hueCheckbox selectAll" data-selectables="savedCheck"></div></th>
            <th>${_('Name')}</th>
            <th>${_('Desc')}</th>
            <th>${_('Last Modified')}</th>
          </tr>
        </thead>
        <tbody>
        % for design in q_page.object_list:
          <tr>
            <td data-row-selector-exclude="true">
              <div class="hueCheckbox savedCheck canDelete"
                   data-edit-url="${ url(app_name + ':execute_query', design_id=design.id) }"
                   data-delete-name="${ design.id }"
                   data-history-url="${ url(app_name + ':list_query_history') }?design_id=${design.id}"
                   data-clone-url="${ url(app_name + ':clone_design', design_id=design.id) }"
                   data-row-selector-exclude="true"></div>
            </td>
            <td>
              <a href="${ url(app_name + ':execute_query', design_id=design.id) }" data-row-selector="true">${design.name}</a>
            </td>
            <td>
              % if design.desc:
              ${design.desc}
              % endif
            </td>
            <td data-sort-value="${time.mktime(design.mtime.timetuple())}">${ timesince(design.mtime) } ${_('ago')}</td>
          </tr>
        % endfor
        </tbody>
      </table>
      % if q_page.number != q_page.num_pages():
        <a href="${ url(app_name + ':list_designs') }?user=${request.user.username|u}" >${_('View all my queries')} &raquo;</a>
      % endif
    </div>

    <div class="tab-pane" id="recentRunQueries">
      <table id="recentRunQueriesTable" class="table table-striped table-condensed datatables">
        <thead>
          <tr>
            <th width="1%"><div class="hueCheckbox selectAll" data-selectables="runCheck"></div></th>
            <th>${_('Time')}</th>
            <th>${_('Name')}</th>
            <th>${_('Query')}</th>
            <th>${_('State')}</th>
          </tr>
        </thead>
        <tbody>
        % for query in h_page.object_list:
        <%
          qcontext = query.design.get_query_context()
        %>
          <tr>
            <td width="1%" data-row-selector-exclude="true">
              <div class="hueCheckbox runCheck"
                data-edit-url="${ url(app_name + ':execute_query', design_id=query.design.id) }"
                % if qcontext and query.last_state != models.QueryHistory.STATE.expired.index:
                  data-view-url="${ url(app_name + ':watch_query', id=query.id) }?context=${qcontext|u}"
                % endif
                data-row-selector-exclude="true"></div>
            </td>
            <td width="10%" data-sort-value="${time.mktime(query.submission_date.timetuple())}">${ query.submission_date.strftime("%x %X") }</td>
            <td width="20%"><a href="${ url(app_name + ':execute_query', design_id=query.design.id) }" data-row-selector="true">${ query.design.name }</a></td>
            <td width="60%">
              % if len(query.query) > 100:
              <code>${collapse_whitespace(query.query[:100])}...</code>
              % else:
              <code>${ collapse_whitespace(query.query) }</code>
              % endif
            </td>
            <td width="9%">${models.QueryHistory.STATE[query.last_state]}</td>
          </tr>
        % endfor
        </tbody>
      </table>
      % if h_page.number != h_page.num_pages():
        <a href="${ url(app_name + ':list_query_history') }">${_('View my entire query history')} &raquo;</a>
      % endif
    </div>
  </div>
</div>

<div id="deleteQuery" class="modal hide fade">
  <form id="deleteQueryForm" action="${ url(app_name + ':delete_design') }" method="POST">
    <div class="modal-header">
      <a href="#" class="close" data-dismiss="modal">&times;</a>
      <h3 id="deleteQueryMessage">${_('Confirm action')}</h3>
    </div>
    <div class="modal-footer">
      <input type="button" class="btn" data-dismiss="modal" value="${_('Cancel')}"/>
      <input type="submit" class="btn btn-danger" value="${_('Yes')}"/>
    </div>
    <div class="hide">
      <select name="designs_selection" data-bind="options: availableSavedQueries, selectedOptions: chosenSavedQueries" multiple="true"></select>
    </div>
  </form>
</div>

<script src="/static/ext/js/knockout-2.1.0.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
  $(document).ready(function () {
    var viewModel = {
        availableSavedQueries : ko.observableArray(${ designs_json | n }),
        chosenSavedQueries : ko.observableArray([])
    };

    ko.applyBindings(viewModel);

    updateQueryCounters();

    var recentSavedQueries = $("#recentSavedQueriesTable").dataTable({
      "sDom":"<'row'r>t<'row'<'span8'i><''p>>",
      "bPaginate":false,
      "bLengthChange":false,
      "bInfo":false,
      "aaSorting":[
        [3, "desc"]
      ],
      "aoColumns":[
        {"bSortable":false, "sWidth":"1%" },
        {"sWidth":"30%"},
        {"sWidth":"49%"},
        { "sSortDataType":"dom-sort-value", "sType":"numeric", "sWidth":"20%" }
      ],
      "oLanguage":{
        "sEmptyTable":"${_('No data available')}",
        "sZeroRecords":"${_('No matching records')}"
      },
      "bStateSave": true
    });

    var recentRunQueries = $("#recentRunQueriesTable").dataTable({
      "sDom":"<'row'r>t<'row'<'span8'i><''p>>",
      "bPaginate":false,
      "bLengthChange":false,
      "bInfo":false,
      "aaSorting":[
        [1, "desc"]
      ],
      "aoColumns":[
        {"bSortable":false},
        { "sSortDataType":"dom-sort-value", "sType":"numeric" },
        null,
        null,
        null
      ],
      "oLanguage":{
        "sEmptyTable":"${_('No data available')}",
        "sZeroRecords":"${_('No matching records')}"
      },
      "bStateSave": true
    });

    $("#filterInput").keyup(function () {
      recentSavedQueries.fnFilter($(this).val());
      recentRunQueries.fnFilter($(this).val());
      updateQueryCounters();
    });

    $(".selectAll").click(function () {
      if ($(this).attr("checked")) {
        $(this).removeAttr("checked").removeClass("icon-ok");
        $("." + $(this).data("selectables")).removeClass("icon-ok").removeAttr("checked");
      }
      else {
        $(this).attr("checked", "checked").addClass("icon-ok");
        $("." + $(this).data("selectables")).addClass("icon-ok").attr("checked", "checked");
      }
      toggleActions();
    });

    $(".savedCheck").click(function () {
      $(".runCheck").removeClass("icon-ok").removeAttr("checked");
    });

    $(".runCheck").click(function () {
      $(".savedCheck").removeClass("icon-ok").removeAttr("checked");
    });

    $(".savedCheck, .runCheck").click(function () {
      if ($(this).attr("checked")) {
        $(this).removeClass("icon-ok").removeAttr("checked");
      }
      else {
        $(this).addClass("icon-ok").attr("checked", "checked");
      }
      $(".selectAll").removeAttr("checked").removeClass("icon-ok");
      toggleActions();
    });

    function toggleActions() {
      $(".toolbarBtn").attr("disabled", "disabled");
      var selector = $(".hueCheckbox[checked='checked']");
      if (selector.length == 1) {
        if (selector.data("view-url")) {
          $("#viewBtn").removeAttr("disabled").click(function () {
            location.href = selector.data("view-url")
          });
        }
        if (selector.data("edit-url")) {
          $("#editBtn").removeAttr("disabled").click(function () {
            location.href = selector.data("edit-url");
          });
        }
        if (selector.data("clone-url")) {
          $("#cloneBtn").removeAttr("disabled").click(function () {
            location.href = selector.data("clone-url")
          });
        }
        if (selector.data("history-url")) {
          $("#historyBtn").removeAttr("disabled").click(function () {
            location.href = selector.data("history-url")
          });
        }
      }

      if (selector.length >= 1 && $('#recentSavedQueries').hasClass('active')) {
        $("#deleteBtn").removeAttr("disabled");
      }
    }

    function updateQueryCounters() {
      $("#recentSavedQueriesFilterCnt").text($("#recentSavedQueriesTable tbody tr").length);
      $("#recentRunQueriesFilterCnt").text($("#recentRunQueriesTable tbody tr").length);
      if ($("#recentSavedQueries tbody tr td.dataTables_empty").length == 1) {
        $("#recentSavedQueriesFilterCnt").text("0");
      }
      if ($("#recentRunQueries tbody tr td.dataTables_empty").length == 1) {
        $("#recentRunQueriesFilterCnt").text("0");
      }
    }

    $("#deleteBtn").click(function () {
      $.getJSON("${ url(app_name + ':delete_design') }", function(data) {
        $("#deleteQueryMessage").text(data.title);
      });
      viewModel.chosenSavedQueries.removeAll();
      $(".hueCheckbox[checked='checked']").each(function(index) {
        viewModel.chosenSavedQueries.push($(this).data("delete-name"));
      });
      $("#deleteQuery").modal("show");
    });

    $("a[data-row-selector='true']").jHueRowSelector();
  });
</script>

${ commonfooter(messages) | n,unicode }
