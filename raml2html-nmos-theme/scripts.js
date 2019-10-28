// (c) AMWA 2019

$(document).ready(function() {
  $('.page-header pre code, .top-resource-description pre code, .modal-body pre code').each(function(i, block) {
    // check if the element contains JSON and store it as a data attribute
    try {
      var jsonObj = JSON.parse($(block).html());
      $(block).data('json', jsonObj);
    } catch (e) { }
    hljs.highlightBlock(block);
  });
  $('[data-toggle]').click(function() {
    var selector = $(this).data('target') + ' pre code';
    $(selector).each(function(i, block) {
      hljs.highlightBlock(block);
    });
  });
  // open modal on hashes like #_action_get
  $(window).bind('hashchange', function(e) {
    var anchor_id = document.location.hash.substr(1); //strip #
    var element = $('#' + anchor_id);
    // do we have such element + is it a modal?  --> show it
    if (element.length && element.hasClass('modal')) {
      // modal loaded event handler
      element.on('show.bs.modal', function(e) {
        // find JSON examples
        element.find('pre code').each(function(index, el) {
          // jQuery up the element
          el = $(el);
          // exit as json doesn't exist or element has already been formatted
          if (el.data('json-formatted') === 'true' || el.data('json') === undefined) {
            return;
          }
          // format the JSON
          var formatter = new JSONFormatter.default(el.data('json'), 3);
          // clear the container
          el.empty();
          // render the formatted json
          el.parent()[0].appendChild(formatter.render());
          // prevent duplicate rendering if the modal is re-opened
          el.data('json-formatted', 'true');
          // create collapse and expand buttons
          var collapseBtn = $('<button class="btn btn-default btn-sm" type="button">Collapse</button>');
          var expandBtn = $('<button class="btn btn-default btn-sm" type="button">Expand</button>');
          // collapse click handler
          collapseBtn.on('click', function() {
            formatter.openAtDepth(1);
          });
          // expand click handler
          expandBtn.on('click', function() {
            formatter.openAtDepth(Infinity);
          });
          // add expand and collapse buttons above the rendered JSON
          el.parent().prepend(expandBtn);
          el.parent().prepend(collapseBtn);
        });
      });
      element.modal('show');
    }
  });
  // execute hashchange on first page load
  $(window).trigger('hashchange');
  // remove url fragment on modal hide
  $('.modal').on('hidden.bs.modal', function() {
    try {
      if (history && history.replaceState) {
        history.replaceState({}, '', '#');
      }
    } catch (e) {}
  });
});
