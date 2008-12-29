$(document).ready(function() {
  
  $('.playlist_remove').click(function(){
    console.log("removing a song: %s", $(this).html());
    $.get($(this).attr('href'),'', function(){ $(this).hide('slow'); } );
  });
  
  $('.enque_button').click(function(){
      $.get( $(this).attr('rel'), '', function(){ $(this).html('^'); } );
    });
  
});
