package og_image;
use strict;
use warnings;

use MT::Image;
use HTML::TagParser;

use constant PLUGIN_NAME => 'og_image';

sub hdlr_og_image_content {
    my ($ctx, $args) = @_;
    my $entry = $ctx->stash('entry');

    if ($entry) {
        my $entry_text = $entry->text() . $entry->text_more();
        my $html = HTML::TagParser->new( $entry_text );
        my @images = $html->getElementsByTagName('img');
        my $output = '';
        my $max_image_size = 0;
        my $min_size = load_plugindata('og_image_min_size') || 180;
        foreach my $image ( @images ) {
            my $attr    = $image->attributes;
            my $img_obj = MT::Image->new( Filename => $attr->{src} );
            my $width   = $img_obj->{width};
            my $height  = $img_obj->{height};
            my $image_size = $width * $height;
            next if ( $width < $min_size && $height < $min_size );
            my $og_image_content = sprintf('<meta property="og:image" content="%s" />', $attr->{src});
            if ( $max_image_size > $image_size ) {
                $max_image_size = $image_size;
                $output = $og_image_content . "\n" . $output;
            } else {
                $output .= $og_image_content . "\n";
            }
        }
        return $output ? $output : sprintf('<meta property="og:image" content="%s" />', load_plugindata('og_image_default_path'));
    } else {
        return sprintf('<meta property="og:image" content="%s" />', load_plugindata('og_image_default_path'));
    }
}

sub load_plugindata {
    my ($key) = @_;
    my $plugin = MT->component( PLUGIN_NAME, 'system' );
    return undef unless defined($plugin);
    return $plugin->get_config_value( $key, 'system');
}

1;
