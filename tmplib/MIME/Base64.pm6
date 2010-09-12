class MIME::Base64 {

    # load the MIME Base64 Parrot library to do all the hard work for us
    pir::load_bytecode('MIME/Base64.pbc');

    method encode_base64(Str $str) {
        my $encoded-str = Q:PIR {
            .local pmc encode
            encode = get_root_global ['parrot'; 'MIME'; 'Base64'], 'encode_base64'
            $P0 = find_lex '$str'
            %r = encode($P0)
        };

        return $encoded-str;
    }

    method decode_base64(Str $str) {
        my $decoded-str = Q:PIR {
            .local pmc decode
            decode = get_root_global ['parrot'; 'MIME'; 'Base64'], 'decode_base64'
            $P0 = find_lex '$str'
            %r = decode($P0)
        };

        return $decoded-str;
    }
}
