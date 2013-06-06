<?php
/**
 * @link   http://dokuwiki.org/template:ospyramid
 * @author Mohd Shakir Zakaria <http://www.mohdshakir.net>
 */

// must be run from within DokuWiki
if (!defined('DOKU_INC'))
	die();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $conf['lang']?>"
lang="<?php echo $conf['lang'] ?>" dir="<?php echo $lang['direction']?>">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title><?php tpl_pagetitle() ?></title>
		<link href='http://fonts.googleapis.com/css?family=Metrophobic' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Droid+Sans' rel='stylesheet' type='text/css'>
		<?php tpl_metaheaders()	?>

		<link rel="shortcut icon" href="<?php echo DOKU_TPL?>images/favicon.ico" />
	</head>
	<body>
		<?php
			if (file_exists(DOKU_PLUGIN . 'displaywikipage/code.php'))
				include_once (DOKU_PLUGIN . 'displaywikipage/code.php');
		?>
		<?php include(dirname(__FILE__).'/components.php')	?>

		<?php html_msgarea()?>

		<?php
		$pagetype = 'article';
		if ($INFO['namespace'] == "") {
			 $pagetype = 'frontpage';
		} else if (strpos($INFO['id'], ":start") OR strpos($INFO['id'], ":categories")) {
			 $pagetype = 'category';
		}
		if ($ACT !== "show") {
			 $pagetype = 'special';
		}
		if ($ACT === "edit") {
			 $pagetype = 'edit';
		}
		?>

		<div id="navi">
			<div class="container">
				<div class="span-20">
					<div class="span-5">
						<img src="http://wiki.oseems.com/lib/tpl/ospyramid/images/logo.png">
					</div>
					<div class="span-15 last">
						<div class="right alt">
							<?php header_navi();?>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div id="breadcrumb">
			<div class="container">
				<div class="span-20">
					<?php tpl_youarehere() ?>
				</div>
			</div>
		</div>
		<div id=content class="container">
			<div id="subheader" class="span-20">
				<h1 id="title" ><?php tpl_pagetitle() ?></h1>
			</div>
			<div class="span-20">
				<?php if($pagetype == 'article') {
					sidebar_scrolling(); 
				} ?>
				<div class="span-13 colborder" id="wikiinner">
					<div  id="wikicontent">
						<!-- wikipage start -->
						<div class="wiki">
							<?php
							if ($pagetype == 'article') {
							}
							?>

							<?php
							if ($pagetype == 'article') {
							}
							?>
							<?php tpl_content(false); ?>
							<?php
							if ($pagetype == 'article') {
							}
							?>
						</div>
						<!-- wikipage stop -->
						<?php
						if ($pagetype == 'article') {

						}
						?>
					</div>
				</div>
				<div class="span-6 last wiki sidebar">
					<?php
					if ($pagetype == 'article') {
						tpl_toc();
						sidebar_categories();
						sidebar_facebook();
					} else {
						sidebar_categories();
						sidebar_facebook();
					}
					?>
				</div>
			</div>
			<div class="span-20">
				<?php
				if ($pagetype == 'article') {
					footer_comment();
				}
				?>
			</div>
		</div>
		<!--! end of #container -->
		<div id="footer">
			<div class="container">
				<div class="span-20">
					<div class="span-5">
						<img src="http://wiki.oseems.com/lib/tpl/ospyramid/images/logo.png">
						<p>
							Site description goes here
						</p>
					</div>
					<div class="span-4 prepend-1">
						<h6>Links 1</h6>
						<ul>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
						</ul>
					</div>
					<div class="span-4 prepend-1">
						<h6>Links 2</h6>
						<ul>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>Wiki
						</ul>
					</div>
					<div class="span-4 prepend-1 last">
						<h6>Links 3</h6>
						<ul>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
							<li> <a href="">Link</a> </li>
						</ul>
					</div>
				</div>
				<div class="right alt" style="color:#777777">
					The template is another piece of <a href="http://www.mohdshakir.net">Mohd Shakir Zakaria</a> for <a href="http://docs.oseems.com">osDocs</a>
				</div>
			</div>
		</div>
		
					
		<div class="no">
			<?php /* provide DokuWiki housekeeping, required in all templates */ tpl_indexerWebBug() ?>
		</div>
		<?php
			//Use the file to store Javascript snippets such as Google Analytics codes 
			include(dirname(__FILE__).'/js.html')
		?>
	</body>
</html>
