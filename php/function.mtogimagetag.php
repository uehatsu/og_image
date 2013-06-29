<?php
    include_once('simple_html_dom.php');
    function smarty_function_mtogimagetag($args, &$ctx) {
        $entry = $ctx->stash('entry');
        if (!$entry) {
            return og_image( get_default() );
        }

        $text = $entry->text . $entry->text_more;
        $dom = str_get_html($text);

        $ret = og_image( get_default() );
        foreach ( $dom->find('img') as $el ) {
            $src = $el->src;
            if ( !preg_match('/^http/', $src ) ) {
                $blog = $ctx->stash('blog');
                $site_url = $blog->site_url();
                $parse = parse_url($site_url);
                $src = $parse['scheme'] . '://' . $parse['host'] . $src;
            }
            if ( $src != null && $src != '' ) {
                $ret .= og_image( $src );
            }
        }

        return $ret;
        return og_image( get_default() );
    }

    function og_image($img_path) {
        return '<meta property="og:image" content="' . $img_path . '" />' . "\n";
    }

    function get_default() {
        $mt = MT::get_instance();
        $cfg = $mt->db()->fetch_plugin_data('og_image', 'configuration');
        return $cfg['og_image_default_path'];
    }
?>
