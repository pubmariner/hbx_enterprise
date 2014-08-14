$(document).ready(function() {
    if(typeof autocomplete_items === 'undefined')
        return;

    var options = {
        name: 'autocomplete_items',
        limit: 4,
        local: autocomplete_items
    }
    $('.typeahead').each(function(index, element) {
        $(element).typeahead(options).on('typeahead:selected', function(e, data) {
            var lookup_id = $(element).attr('data-target');
            $(lookup_id).val(data.id);

        })
    });
});
