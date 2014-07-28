$(document).ready(function() {
  $("input[id$='include_selected']").on('click', function() {
      var select = $(this).val();
      var affect = $(this).closest('td').next('td').find('input');

       if(select==1) {
          affect.prop('disabled', !$(this).is(':checked'));
          affect.prop('checked', false);
       }else {
          affect.prop('enabled', !$(this).is(':checked'));
          affect.prop('checked', true);
       }
  });
});
