// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

var popupShow = function() {
  $('#back_fader').show();
  $('#back_fader .popup_content').show();
  $('body').css('overflow', 'hidden');
}
var popupHide = function() {
  $('#back_fader').hide();
  $('#back_fader .popup_content').hide();
  $('#back_fader .popup_content').css("width","");
  $('body').css('overflow', '');
  window.history.go(-1);
}

var miniPopupShow = function() {
  $('#mini_back_fader').show();
  $('#back_fader').css('overflow','hidden');
  $('body').css('overflow') != 'hidden' ? $('body').css('overflow', 'hidden') : null;
}

var miniPopupHide = function() {
  $('#mini_back_fader').hide();
  $('#mini_back_fader .mini_popup_content').css("width","");
  $('#back_fader').css('overflow','');
  $('#back_fader').css('display') == 'none' ? $('body').css('overflow', '') : null;
}
