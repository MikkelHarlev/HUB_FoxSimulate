function CheckPar() {
 if(window.location.hash != "") {
  var exp = /#nav=([0-9]*)/i;
  exp.exec(window.location.hash);
  var ShowId = RegExp.$1
  if(ShowId != "") {
   ShowNav("NavBottom_" + ShowId);
   ShowNav("NavList_"   + ShowId);
  }
  if( ShowId != "" ) {
   var xLocation = window.location.href;
   xLocation = xLocation.replace(/#nav=[0-9]+/i,"");
   if( xLocation.search(/#/) > 0 ) {
    var xAnchor = xLocation.replace(/^.*(#.*)/,"$1");
    window.location.href = xAnchor;
   }
  }
 } else {
  ShowNav("NavBottom_1");
  ShowNav("NavList_1");
 }
}

function ShowNav( id ) {
 var element = document.getElementById(id);
 if( element != null ) {
  element.style.display = "";
 }
}

CheckPar();