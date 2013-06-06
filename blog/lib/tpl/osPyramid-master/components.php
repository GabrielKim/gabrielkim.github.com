<?php function sidebar_categories() { ?>
	<div class="widget">
		<h6>Article categories</h6>
		<ul> 
			<li>
				<a href="">Category 1</a> 
			</li>
			<li>
				<a href="">Category 2</a> 
			</li>
			<li>
				<a href="">Category 3</a> 
			</li>
			<li>
				<a href="">Category 4</a> 
			</li>
			<li>
				<a href="">Category 5</a> 
			</li>
			<li>
				<a href="">Category 6</a> 
			</li>
		</ul> 
	</div>
<?php } ?>

<?php function sidebar_scrolling() { ?>
	<div style="position:absolute; margin-left:-80px; position:fixed">
		scrolling <br />
		sidebar <br />
		items <br />
	</div>
<?php } ?>

<?php function sidebar_facebook() { ?>
	<div class="widget">
		<h6>Find us on Facebook</h6>
		<iframe src="http://www.facebook.com/plugins/likebox.php?href=http%3A%2F%2Fwww.facebook.com%2Fpages%2FOseems-Solutions%2F198161763569626&amp;width=230&amp;colorscheme=light&amp;show_faces=false&amp;border_color&amp;stream=false&amp;header=false&amp;height=65" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:230px; height:65px;" allowTransparency="true"></iframe>
	</div>
<?php } ?>

<?php function footer_comment() { ?>
	<div id="footerbox">
		Comment plugin such as Disqus goes here 
    </div>
<?php } ?>

<?php function header_navi() { ?>
<ul id="category_menu" class="sf-menu ">
        <li><a href="">Home</a></li>
        <li><a href="">Menu 1</a></li>
        <li><a href="">Menu 2</a></li>
        <li><a href="">Menu 3</a></li>
</ul>
<?php } ?>
