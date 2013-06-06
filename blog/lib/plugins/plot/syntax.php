<?php
/**
 * plot-Plugin: Parses gnuplot-blocks
 *
 * @license    GPL 2 (http://www.gnu.org/licenses/gpl.html)
 * @author     Alexander 'E-Razor' Krause <alexander.krause@erazor-zone.de>
 */
 
if(!defined('DOKU_INC')) define('DOKU_INC',realpath(dirname(__FILE__).'/../../').'/');
if(!defined('DOKU_PLUGIN')) define('DOKU_PLUGIN',DOKU_INC.'lib/plugins/');
require_once(DOKU_PLUGIN.'syntax.php');

if (!is_callable("file_put_contents")) {
  @require_once('/usr/lib/php/PHP/Compat/Function/file_put_contents.php');
  if (!is_callable("file_put_contents")) {
    echo 'Please install dev-php/PEAR-PHP_Compat or >=php-5.0.0 !';
  }
}
	  
/**
 * All DokuWiki plugins to extend the parser/rendering mechanism
 * need to inherit from this class
 */
class syntax_plugin_plot extends DokuWiki_Syntax_Plugin {
     function getInfo(){
        return array(
            'author' => 'Alexander Krause',
            'email'  => 'alexander.krause@erazor-zone.de',
            'date'   => '2006-05-23',
            'name'   => 'Plot Plugin',
            'desc'   => 'render functions nicely',
            'url'    => 'http://wiki.erazor-zone.de/doku.php?id=wiki:projects:php:dokuwiki:plugins:plot'
        );
    }
  /**
  * What kind of syntax are we?
  */
  function getType(){
    return 'protected';
  }
 
  /**
  * Where to sort in?
  */
  function getSort(){
    return 100;
  }
 
 
    /**
     * Connect pattern to lexer
     */
    function connectTo($mode) {
        $this->Lexer->addEntryPattern('<plot(?=.*\x3C/plot\x3E)',$mode,'plugin_plot');
    }
 
    function postConnect() {
      $this->Lexer->addExitPattern('</plot>','plugin_plot');
    }
 
    /**
     * Handle the match
     */
 
 
    function handle($match, $state, $pos) {
      if ( $state == DOKU_LEXER_UNMATCHED ) {
        $matches = preg_split('/>/u',$match,2);
        $matches[0] = trim($matches[0]);
        if ( trim($matches[0]) == '' ) {
          $matches[0] = NULL;
        }
        return array($matches[1],$matches[0]);
      }
      return TRUE;
    }
    /**
     * Create output
     */
    function render($mode, &$renderer, $data) {
      global $conf;
      if($mode == 'xhtml' && strlen($data[0]) > 1) {
        if ( !is_dir($conf['mediadir'] . '/plot') ) mkdir($conf['mediadir'] . '/plot', 0777-$conf['dmask']);
        $hash = md5(serialize($data[0]));
        $filename = $conf['mediadir'] . '/plot/'.$hash.'.png';

        $size_str=$data[1];

        if ( is_readable($filename) ) {
          $renderer->doc .=  $this->plugin_render('{{'.'plot:'.$hash.'.png'."$size_str}}");
          return true;
        }
 
        if (!$this->createImage($filename, $data[0])) {
          $renderer->doc .=  $this->plugin_render('{{'.'plot:'.$hash.'.png'."$size_str}}");
       } else {
          $renderer->doc .= '**ERROR RENDERING GNUPLOT**';
        }
        return true;
      }
      return false;
    }
 
    function createImage($filename, &$data) {
      global $conf;

      $tmpfname = tempnam("/tmp", "dokuwiki.plot");

      $data = 'set terminal png transparent nocrop enhanced font arial 8 size 420,320'."\n".
               "set output '".$filename."'\n" . $data;

      file_put_contents($tmpfname, $data);

      $retval = exec('/usr/bin/gnuplot '.$tmpfname);

      unlink($tmpfname);
      return 0;
    }

    // output text string through the parser, allows dokuwiki markup to be used
    // very ineffecient for small pieces of data - try not to use
    function plugin_render($text, $format='xhtml') {
      return p_render($format, p_get_instructions($text),$info); 
    }
}

?>
