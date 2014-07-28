$(document).ready(function() {
  $('.btn#Plans').prop('disabled', true);
  $('#Carriers').change(function(e) {
    $('.btn#Plans').prop('disabled', false);
    $( "option[value|='']" ).remove()
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
    var id = $(e.target).val()
    $.getJSON('/carriers/'+id+'/show_plans', function(data) {
      $('#Plans').empty();
      $.each(data, function(key, value) {
        $('#Plans').append($('<option/>').attr("value", value._id).text(value.name).append(" : "+value.hios_plan_id));
      });
      if($('#Plans > option[value!=""]').length == 0) {
        $('.btn#Plans').prop('disabled', true);
      }
    });
  });

  $('#Plans').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.date_picker').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.btn[value="Calculate"]').click(function() {
    $(this).attr('class','btn btn-success');
  });
});
