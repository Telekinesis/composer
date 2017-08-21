ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� "��Y �=Ks9z�Mew�[�n�R9L��v���$��ݤ(����-��,�^-���N?HQ.�/�1� �T�9䐪\��k���*#U	�n�͇^�Dό��D>| ��`kmd�4��b��4-���c<��$����4.	��4I� ?��S���B��XTT�ڿ2��- 9����pו�DSY���M�Lz�q6�z���M���	k�|��L�&�NM�A��RV�w`��]d��DVdT`)�Ŗc{(�g�I�<cy���6;�tF@����^%S>M����&��/ ��� |5�k8)l�HsH��-���o�e4`��5�e��6j� N�9[B��H\�ݧ��,�K���ۓYV�İ0_�!�>�8_�F�ChTl1�Hw�x�#���k���ԡa/hC� �:AT�J�UGaR�v�̍��Z%�iu��HįF��5�i3.(?Wu8��~���D1죮���`;v7���{VS,T��!4�`.'���K��`���s�|���lw�s�tѭF�B?��vʻ���8����3Âz�-n�#z�9�.+NK\�!o%j��:��љ���Lz~j��}������&�L����fZ�W"��A��Lh�4Ѵ�;�a�O���Q/D�?a�Ƚ�A�|<�\f�i��� K��ˢ{�{�dA������w��oz*l�������%�ο��J\���	���%�'_Gj��A���ص4��ρVg��Eu��!�V�O+{�T��~ȃu|�����S�����{�,?im����Oe�N�'�)���e����i��w��&����{i���ȗ�������� ˢ@�䨸��e$���_癁-�x���a!�x��{��"TX���:��=��Ym����t�������E�V~�]K�A���X.bY"広��x�8�,iꎿ$��m��%%-�F׳��{TƆ��9��C�iakv�&����3t�6k[%R�B!��̡;4dMY�,��@�#*k��Z�5��ccåjSB����E&Y4k�x{ʣ���:����QAKk�=�7]�B!��no�����A�{�[2��v���b�C4��6Xn�y�{EbX�ayEd����Lɨ�f{ACn�2�.]��S#�N��^��I���I����@�%AV��KIA��{����6Łӂh��Y��"�X�i�fsr(`s�J����׹�/n=}^g,�6�����z��"� ��<޿�(M�
���!�Qܐ4;��7�w B6b��A���3��I��t�0غti�e��Q�7i�� ����!��x qp��)���������lB�����]O�W�*�uJq�`A��c�iO�}xL�s;����"�Nydd�y�B`g���i؀����OCK(��t�bE�Q�}tQ�����Di�c�q��@y0�~%������@��-]k�<��9��1'���F�?���1�ic�:�#�@7���~ON�މm�)�oF�6���� 5���W���ǀ�м���H#p�\w�|dC��c�,����H���C���� ���2�j���N�2����5�/�R|V�����r��'�'�0�w��-�=����u�,l��vs�yN�kY����րK��[�N��v�rZI���խ?݄�j�G߳+�+�gO?���(I�Y]/7�&����a�\��_�'n���N ��i#�%q�m�C�"p�9�\��� 6�'�H�ϞNb�Je��JU-WO��Bf�z9�S`�h��Fd����\�jo����Zh���
���OYT!�k��-x���?���߃�9����	����t;5d��o�W�-"�K�䚎���?�����������?����"��1b��FV���ȸ�X�[��(���夕��y���?h9�� �N���0��ŕ�J����_��'��=1���dB�B]5�s0���@߲��Ν���������?�B\\�.#]?�l�s'.�N���_�I�"���1	��_B����%(���� ��%1*���hTY��,%͜�f�*�dn�@�����k���v:Ь�a���C�w��O��7��J�u���=*I��h�=��4|����݃����%Gj��z��;?&���E�QX��yr��ꀐ� 
��_6#��w�̓-zxrO&�m�!,��:S�� x�;s�L��;F&p�ć��n��f h�<��2�T��%(�:��3�?������~�����@��,d!�"O�	�����(���z�\Mo9n�o�NcrH�1��U����5d�nUÿ({�V�����:5�7���\'�d�7��+)+�o9�A�9� �R��͖jc"��(x��>�Ld��G����*�T��r(tm�/1���?9.�����*�r���f�D�G��gP� ���= ������:mB.u/��i���/�D	a���0��vI뗮 5��{��˂�n8j�vы��K|xd�[ �K6`�[ ���x�|�O,��y��n̾�1UG�_��!�}X�]b�#3oK,|6c��ٗ2��1U!�,�tWg^gy�a{��^�,��O�\��I�>*<7��Q2��.�x��M&2}���wT.��ŎfL}F�?�tc�?�p������x4���_F���O�������um�	���/��i�OQ�����$�~��r���W����������of�ϷߣhM�dYJl44Q�l����H���$Kq�d�19QKDe�	%�k�E�m(���}����,����_�ݮ���8"k��~���7ok��z�q)l��rt����kí���$���b�bM��/��_q�doG�k�]��/�b�}��/Hٯ�,�!�����Ǥ�����h�A������p3"?�,_�n/��ýU7����?�������>r��ϱݤ�k��4?��_�����+���K����$o���-�Ǥ7I_�A�:�~�I)2I�AoT�g6�����z�������Q�!�	(�5-�6	���چ���(��Jl����ō8L��8�	(!M�clxU۠6�v'DS2��A*S����ZͰ�wf!�O��R)UK5�~>�6�e����z$��7qg�F��j�w�I��L�ؾv��%�vN2�V!uxX8�\��d�xHPUS�b��3:��keγg�W�UӇ�LO�ޙZ'�K�ű�q���o<\������{�ժ�I�'�&	��iz0�jF*�ޙ������V,T�~�,/�ya����h��Fy�̣�d�P����q��T�e��.2�8ڻT��S��6<:�i�{\��%����;�@ʺ�����H9�o�g��L��������<RT2f��(�u�ܹ��)�j��	�d!��������R)�s?��
y5�s7vΓ%1�>�T�x�/�яw��'�&�pT��Nn����øQ>h�u'�]W
��I���(V�y�P�/�N�� ���U��݂*�� ����L2�/�9�n����r!�662ꙪR6�U=�/��5��X'Ѝ'���;�*��;��"y��g	�l��K��m��nA�㞑L�BS-dR�RJ�wJ�wf*���V=F��H(G�H�<yO�T1����^�i�e'�;�׃:��Lf��B"�Vޙo��P�)9�Ջeu��X>SL/~8�#�����l��f��tL@�3[?�_����/ �bL�=�D�T�c�*�����#��]uw�>����JK��k�����(*���[F
�I���!1`'s�rs�|n��d�*��	}H}�R�)���nr둄ޮ�s'{�Pߠb��0zF6����Nɔ�q�R�Z�z)�tP,w�,L�_\ʝ��_�P�1'���2P�R����L�����Ꞅ$����;�MoW�A�BR�����ا�O�q�y��++������[��]_�G?�/-��r|e������ ��O������폔Zo��Ւ�.5����L6} ��ׅ��E��م���c�eO��vin��{�-'Z���+���/���~_ܵ�������j����VЀ�R��G��>B�]������~%�������?J4���ZJzR�;�X�d>Y ߬n���4�e�����X����Ю��m���m�����o	�_"��=/i�j�<�4j��"�p�FuAS�`�6�@6��'~�0q�ݐ�O�����_������"��I �q��&�W���n�b�+]��Y� �EPC�$�j� x`���a�L~�lێ�?>��?#��{c.��m��#J���2/C?������f��`� [G��KG�d�	k�w���hݡ?W`!�H�Y� ����3Ԯ��*@�� צ��}z�M���UD�:�'��6�1M -h�4���X:�	����m��)I��c@L�Q���Ɍ��~pu��X��~��u���64m��W:�� �3lz��|��h�3Z���9~�胶�����:��g�p:Ѻ�"�_r0�}�����ӈ7�F����u~8�o'���H��ik��i��m.�`��F��5�@u	&"B~�/���.e�2�c퀶����$O�x�b Or.�����q+�)��&��ɵ�M��]�:Ȗ�E�����$ՠuI���)��>�~!��OnOO+��F[�W%�j$_G!�6�f����G��e </%�m�Wo#/P���WK��'�]�	�#�;�.1~��\R*���(������K�8}���|m��9x^���}t~7Ǣ���'�R��X��x���<��zxJ��H�X7�+��2�C�K�(�pm"EDW����vZ>>_�{/Y��a�i�&���������&� �B2�m����1�5l:����8�:��7m�ދ}�t�a��8c"2D����|�C�1O�i8$�P|0q:���������R�
���2�k�u&a���X��Qĺ;3A�,�?>���Lb��0��+۸z�/�Q�����$��/%q�W�=�s�w�?�׿��������|�����g�Zb������Px��Q���Р!��R����t[;v����(9��8q;q�հ.�+^bu7HH��,��W 6�,a{l����Q���J��䌦��>����w�����o~�����o��?��G� G~G�o����O�;�k�~�Ȇ>)4���ɈJ�e���*)+T��H�l�Z�c1�T#2N�qI�[���E�e�.@)�BʱV;�4��O�n������{O~::��?��M?��[#���C,��X�_?A�_!k�����'�@���>����w?��G�����>
�ۣп<Z���� �F�! 0V�1e�Ɗ\����b�cS���
e���1�l�s����b�cz� ���"�<| X5E������*�-�#�5+��"�32J���%C���\�)�ה�g�Y���iq�X2�֨0z�"�D�w�&�֘k���� �h��XjXI�K�^��@vJ�L�5ȍ�Dn&��V҂N�9k��=�jd��[�Tu� �X��T��~��5���78�F�E[�4X.�����4�`r���fQ�oR�U�h��S|i�B�놮�L2�)�K��~�.��ܬ�_X3%U��vF�+�T1�Y�f	+0�4�2��wR��A�Xƞ�i�6	�`,΂�+N�� �ْC�Y��N���L�"j�4a��
s!]�f���#�����"������܄)r%��#t�Iի=�mH|G4�y<�S�c-[�'ǝ1�0�6�X�f����:��U��f�r�,1�a���[t%?7��Sa�Tx�����QFW��[��쏯妻�/���/���/��b/��B/��"/��/���.���.���.���.�]��+��y��f��{�'Eg��ZF)s@��j���U�R��-q:�kbz)1\l�⍨��ź��/�{�z�PL7n�z�{n�zbV�n ���7�V�v����YW]��+���id���&���Z�Y�T۽�>K
�x=M��L�x�a���M&��,Y�/�Mpb4�F�J�����WQ?��Q�L��$$^�s��Y�0t2�������QY��H�xa]�~�LzF��82�qZ�$ա���V9+9l�;qmAE�L��	�9�F����}B�S�ӚFW����]@dL�$�����,F�+��{7�����k�_:z;�$tz��������ns��_��w�%P�n��
�ǾF'��p	�Ϸ�������/C}/t����	��C�O6�[�e/���ߧP���˻�wBo���X�O����G��y���#��\���ӿp��?
�ѣЏ���ÿ�V�e��(������,_14���9>Z:�e��������I�){:?Al�}�J:���-
�<�\�m�f�V���Bnc5%∮��w\�e���Ld�����P`��+L���]e!�+�!�� �ňf��Ev�'��)��3�ܸ�${E$N���T��\~�	�F�X`��v�m�Lb�R��8e��&�1��<$3Mgj#<f!g&�H���P-KO"��rZl�����)��� a�F����56�J-~9�X�hLUM'j�Ѩ)�F��/�F�<����_2�Ț�������hgʢ_8K��J�:�p���E��Y޶ :�B�Ơ_�ڈm�t�V^cF�Sq���.�+���0[zm�^F'!��_e<��k�&�o(T���8�f�X6ot���rK��_��������즁�\25�@������X���k,r=~�����>��	�3�f�z|�cw���;m��p�g��~��O����p$��\f"˞lZ=Y0gI/dD#eT��Z�+�e%�E��u�X+�e�ϑ[�*f�*�q��\]�3�i�^m��ܸ��D�ء�Fd,�P�C9!2�u�0K�M-a�tꃹH�:�)t��������h�{qj���v!��P�$RqKU��
KE�ˈ���}+(�fMɤ��JU�rt�A؈*X�)��y�T���U�X*�R���&�QFm�ɗ�]���p��$��(�Y_��M����D��b�H��lPϴ�T��lV�Jq�*�Z�~��J1�"�'=�QGn{#�,�L���x�Y��W*�ގyʤ�yO� �=��
��F��Z�41>6h�\��u��||§���O�Z'b�f�,t~y\���ˍJ�f��z�:�uS}��4$��N�F��BA<��C�D��F�"r�/�KKR�1����M��B����K���lH^_��D7��c,�!3T�5��\�3�
sv��� !u�R�Q���a�Z�X�<o`SiвD����%��Q���f�]����b&�,��L�_}fۀOv釡��[��g�޼��7.����!����VF�C�"����� �\[���Ds>�������8�U��Ԩ,�J���{Ȼ�H�Y�!?�(kK%�8����7�|���7a�V��d��C0�79O6E�xs�馣	?�W�G,�dR�tMvV\V�?O_ �%D�e����� �qE�?���/º9ɔ�e��s:�Ss�v���. �����D1�Q��ȧ.�)�5:��t/��f�+������!�:������Aa���FG��?�q����t?�_��>�	���Gݿ��9MU�wr��y�3 ����6_w���;���p�a2�J2�ci":�yq�!�w ����=.wD�	����sl����}�{����~����W��AUk�At�z�0�ǯVG=���g��"�[����E�U��W�藓�8�Ѯ�-� j����zz��Q�H��z?|�����B��DKz�u���b`�`m6�OX�ms@�L btE�T�>H}c�=\ 42�w�ؤa�6�S�� �fq/��Â6���.������� �˭O��/O��jMMO@���+��V��&$�C��_�`���.��z\ w�ADVТ;��1��X���u_t �w�Wδ�h~�ˬ��A��	] R��b �'��^��*�L�*�?9m�a[�hr�%���u�m���ю_�S�Ix��:�{�"4`j�c�m�t�
X`j۔��z�[	`&ڰ��%�$\�5����%d���A.'�/�^H���f����o"lo>�����;�4lwGp�`C�~|��
�߮�M�.~=�D��W5�$��a@_��m�VO�����@t��T��K�^o����0�y�ŗЀ9���V�� >������
�0HJ����4�����е��řË0t�-�����!9�FX���AI�^ɚ(:D�����6���r_����}'��� @�+�K%��D{Ꙥ��e��~�ALﳾ��%v�6� �8m���'<_�����1��Y��_i P�P�؏A?-Iqԑ��*T
�@YXO���$L뵃S`g�����z`wF���A΀$ xU9�cM�H��bf�\L���+��=���
7i��恐�`kL˞穭�A��´'ٙ+��v�-�x�Y�:(��W&���ÒW]\u��JĹM�-��ca��� �/p�e�{c��k�_������6m��q��@�v�n��n��4���*Y�Sl5�`WB�D�ԝ�S�''���ɨԃ�a]3 ]�<��8� f�Y]W�F��\� <tX(����Ñ�n�xmm�i���h:/�8'V�"x9�5��.���E�[@8BSv7��t"�����}7��f*�5��]��n)�vḡzl?�@
(�����1�Ů�}-vp�7\�}������vL�k۸��?%���);���K+�K�K$���dG�GV�@k'7��rv<���I�-	��sBc�D����%��|�Ɨ�o9ƮbGo�ϯ*>�%��_m[��<ξ+�4t�7^�� dI�Pt�����DE��Ҵ�n+*.GU\��V��?N�-���i�$c�D�ҹ�w$�{����@�'�
|����n�y;��f�7��~���(v,�?aN�}e�jU�q�ESR�����%'��IqI�h��+Q,Fǔ�ԒA	)b�d,��Q�hI�'&��� :�?�V���%���m���t�@_y�ܖГ���]7�ٹsQn�wmv�ߑ���}�R�͗8�d�u���%&{�ͧ�|�Ͼ��ִsy6�\�sǕ�r�%�+����߲P�J:Ͻ����d��_���%W֮T�Ɋ����]�ĺ����{�]�dT4��';���:�hgN�Pc�F;�ٝ� 1m/�:�z.*vp:�4:;�����6�zӵ���@Q�B����٭�>"�M�W�\N��1@/%�D��*O	��y��K��'Ҍ�K�UN�)8���ֳ��s>��B��r:��'(�����L�����5�^A�%A��6I^y����%�	O�6����v�t�\I�sI!u��+�|�T�G�������F�x�9���d?uj/0��6Ӏ�ܲZ�K�e���;?9�°L�� �P9����|5��XwL�_�y�T�x�|��n�5)x�ܝ=xm�*�r	��B���c�q�OD'�4uwƿ��ǳ�nb����|�v�+��r�����X��������6��K@yԱ[_����7;���Xr@�+*�!�8��Z��ml��Ё���A�o�}�����Ł���!�(N�n�;��G���o3�6n�����E뿏���K@�f�#M��A����m������>���m�6aCii��O�����?�c����;���O������_��4|gӾ���q��l������������������~�M��+�a�Q;�쿽�}����]��`1L��dܖ$��-5B�Yjǣ1���1,�F�*iEɘ��d'	�}n�u~��C��Gh|��;������f��W�i��g��Ԇ#��N��q��^�i�i�B��#����/y�?�$*��Z�[� ���ƌV#
�5�&�+-
��XU��U*�fDZ6��~�tR�4z�N�4���D-�ŕٙ��1�s�����������?����t������q�����?�����?=�O`;��#����/�	0�M�;��� �߼��:���у��Gz������|��A�����xt���`��%= �o� ��h�� ������ޖ��A��#=,��~}@��/�K�_��$	zK������>�!N�!N�!N��4��N�A�������� 쿶t����t�����!���g�ښE��=�⽷j�|�x�>N""(�yO��(���$v�Dg�Nw���u���I]����빛� �/	5��� u��)�~�à�/o�������?��ߛ���د:\;�������E%���.$��O���������1Do�����~"���s��XV	�O����}"K�� ��e�P�s���v��63٥�������{c�:R��V�o�:�h�n,}d^�Z��¶�1T}�Fj�y[�D~d�S���-��Q����z�5�v�|����T�ɹ;�,g�tK��ާx�-�+g�&��{�ı+�h�]��5���i M
�{�DU������r�^ٰ�1�i�w�/w������3�fV�w3j����_j���D��P�m�W���e��CJT٨E�� �	��K�?A��?A�S�������+5�Y��U���k�Z���{��O���Z���o���Q�����Û����������	���d��h\��Uܧ��������W�������>wGó.�}Y�������N�4䉏�T�fq�G[onk�Bp�j�6�%:��\�f�FNvUA�rL,8��l�#zF�&��O��R6�0t9{*둿��!���S]/?��:���sI�D3W�/m|���oߺ�����y���v�#���q�Y��&��p3�/�	�B0���*���|�>t~8sMR��劉.7l�9�Φ*'�]�K��pmL������������+5����]����k�:�?������RP'���|�	f6P�R,�,�R�hH���Mx4���D@�>�pF�����(���r�+�����j�S,$�f�i�H�d�qWp�t�s☷-}��|E|��7Yvjm��`~���aH���9g1=`b� �y��-ǧ�y6�|�!D?�1R�Er,IN����a2��fDE����Toچ�����������+��V�:����������5�����ǥ�������C�W~e�w0L�>hr�ELd!w0�����ew'���.�
��p���.A����1���p��Q<�hΑYnŁ(�\]F� ��H��j�W�О�5Z�t���)�F6mߥ��{/�q�����5�����w|m�����U����/����/�@�U������s��.��_	xK���E�E����~D�����z�tO&��ir��?]T��_��[�k3Ȑ�ښ�� �Ӄ?q �g=����T��*X��*r=��3 x�8Kȁ���Fw�Z�l�%�tw3��h5�����faY�@� oD�`�e�1/Oet<_ډ��s/���-8c�Y/"7ȑ�5�Q���9O�W��`:-!ׅK=�"�%\�'�/�q`@��v3�������X��uB�X#�ʲƸGX�� -���y�4��[a�����ED?��I�˦��C�v���d��N��Dkq<�Ijw�$�l��i��u�XX�\3���}	�_�׉�&G��>b��$Xst^�m;��hP����	��|��?�`£�(�����C��?(����2P������/��?d��e����S
����������6�	����P���8ϧ)��}�dQf�M1<$��<ϣi���ِ����4���)˅$b텰��i�C��`��b��S
~������BMj���6�P����x�����!YІN&&���Z����?[VA.�d�*.zض�c# �5!��x���=��fo=:i�wȕ��3zph뎃s��N�H�e�z(�n���{Q��?F>8���R����x��Y�e\���4���_j������%�����2����������?��+	��?����\���?���3����7�߯��@�>�mz���8O��rN�L��˕y7���K�w���qc������1�gf���l�g��|d�{oD�;Ղ��9��X�$���<Y�>L�G��m����4GF�#�7��hȬ�l�i���VS:�2n�K�a1j�O��%���¶��Γ
r��J�Y��kێ�w�s��A8d7�.sm�M�V�^��C���x�j��w��ʎx]vD��L3iD���oOB��
�q���m0�J��f��C�(N��Y�F'k�s�&�DN=Y�u�9X�x����E�c�S���.u����V�r���^W@����_��r�!��"���0^7ԡ�0�M��W
`��a�濡������~��PK@����_���աt��\�������_����@�/��B�/��V�������+��?d�Z��<F��#�?�)���(z_���e�,�<������_=����U�b��p����_9�c�?@����?�CT������zp����z�?�C�����G��(�� ������)�B�aw�/����?��P�m�W����?��KB���B*@��G��?������������H�A8D����k�Z�?��+C���!�F-����?��������j����KA�_G0�_�����������+���怒V������?��W�������W��?�Z�?���@����ex���.��@����_��x�^���C���.b�GC��gh����X.����!�Q4;�����������y�G������/����A�_�T����R�G�'��_i_*N��*PAAs���f��j��
Z7�x�ӈ�㇨��CC�V�UK
�b���0�����Q�L����,Z��4�!�WI�#�.��9��TkRΰ�+q$�G'Ivq/���s8w�����P��.~/��T�/x�P��?�V�����t}+E��P�U�Z�?��T�������RV�b|Aԁ���������N�����-E���,ۋ��(��������O��R���ro��Q4�^��w��:�Wɜ��(bRO��vj�ۦ39�n��IzR�m�K����0G	M=H�͢?�)����������-	5�����w|m�����U����/����/�@�U��������#�����-��{��S��?��	q$��56�ő"����_+����Y�]��$���`��|���d�i��-S;h6���Ҥ՞�~��1�J�v��l,�)�hD���i� ��/�=���a��nD�dAz�gd���Ƚ�E/��5���҉���i	�.\�;!�[�������,��=�݌�~h(ǡ �,V�w�P(֑ʲ�1�V/3HG��^�MQm3'��r�>?�?�D�Nս�<���{rg���5�����XP�)�m�����4Z���)��I���T#<l�es�I)fk�����I�Ov�p����w�����F�O��28�K�g\��|���������/u��0�A�'������?%���WmQ���q�'Q�/u�����$�(���s=!ӣ~(���1��y��]��������(������8��t3����qBw:�����ү��hI�u������$W�7��n����s?t%������q������K�7߿�.=]�n���j]^��kj	��ؒ���B�8����u�!��Y�a:�@�FF�����)m5Z��NV�e*�?���5-5��a����9kb4)a��z�8�p���=c�-�c����[�쓕��y�[;wu���M��׼��o������!���ŧ��T��X��N�-����Ƚd�܌:�fۤ�?�Yz�޶_�̑��%A�c�wc����P�:`�t8�]���S�?�r�S!�X�H���izBn�&��[��.Ч�Y��ܔ���v�`�Y=iՓ_��Z�?�n���%��������̌�H��fD�y��I:�f(��8=�Ip3�`|:�4�9�� ��f�g������E���_)��������?���_�("���d�����vN>ݧ����B�2�/W��V��ȕ�Z�����?�W���������������^���W
J����Wc�q�������?
�_)x���W������{�س�X���!3�1=�w��g���y�e�NΩ'��j�!��������������o������|��퇼��3�xo�M��Zm�@�t�!����0��6�֘�[��?i7�5�wcmм��� K�|rI>cg�b�nu�XM;ë�|����~�����b|3�yg�4�a�a���ly5:��I�J�#^�,^C�~|<���X�1{��C��1C.ǽK����4����D��T��R43�֜�pN�{�tG�C6U_Y��Ye��������4�������?���4�b(1cq�����W�3ߧ<�c=��Kp�S�pǨ�#�`�}"ʸ�?��O�o��>���k��u�`�ޢ���o#'N��+�q"���^ ���v�����l��䣲����?�׀�����W��.j�^�����@���'<�����U�?�U����9�A�AY�������g0��K�[����;�ќt���M����l��E���>�!����.������s[?���(���-D�� ȱd˄.M��B>��l���c��cҷ���B��:W�G[W���tt傟��y�촖�hu0��Ex�{���&�����+����n��<�[;[���[[)@^> E���}��N:љt2i.ϧ*[�
�{ν看���pT���<��q��lm�y��S9l[�Y��y}��@�c�;�񱶬0��{0�Y�[���i�����+-�Ĭ%p���jV�+%�L�)$������� $���B�����x�o����0�]��w������iؒ�4l��edK�ڼ(��O��*��ԶcR��ld���r0�U���TL,ZJ��6�f�����+ؕS�벵��R���I\�j��I�.���\��������7��dB�����W���m�/��?�#K��@�����2���!�; ��?!��?a�쿷��s�a �����_���ё��C!�������[���3�A�7���ߠ�;�o���W�B}��o������?C��������;��̈l��"�z�� ���^������o&���Ӹ �k@�A���?M]���O�R��.z@�A���?se�
�?r��PY����H߁��L��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\���R���� ������0��_��ԅ@���m��B�a�9����\���R����L��P��?@����W�?��O&���"׆�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�K��~h�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E�����[ݺ?<y��"w��C�6���;=e��Ex�:}���`W��ؔ��F�7�r��,IO��j]��D;�t�6��&w�Ɋ~HS,��8�m�/k��Ȏwd�)9=�4]=hzV�E�u:,�q3,E����m�-��d�U��\OS���՛�nǮUc��Dy�'^�	�$Y����d%Pݏ���E�n𜑇���U��`�7���y���AJ�?�}��n��%��:���'jv����^����QHʆ���m��m��Ƶ�֞����Fu�l�[��r���#7�����,El�T8��nU,�v�-ߪbӰ�sUk�����f��=mN/��&�H;z��%�����7�{#��OD.� ����_���_0���������.�"�_|��ߣ���h��[vւ����U�rU���g�զ����x��&�d*З�gv�8�|�{9�&�� 6�޸˒$�����֩������mݛ��H�ǅ���>"�9v,�A95���d�i�Z��4W�<(j]m[)E�}�a���^7M�9[g�p��OY���0������g�CѮ�ĮQyLSH����O�{Ex��$%I��;�YU+�k���{i�a/l>%��j�[(�xl��У��lԚ;�Lkl�:�~��L��a/���R\�0�V:�(	������o���1���s\�6dRk����k��6�K�`�Q,�B�[��O;@�GN������y�Q�O�?!���Ʌ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�?%��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�����,���P��?�.����+�`�er�V�D
���m��B�a�d�F�a�G$����.�I��Ȅ/�O����%.�ڃ�;��Ъ�	7����m�m���ԺO�	���qJ���-�w���q�2��~�R?�W��N���9������<���.�[t�~�+�Z��r�*AǬ-�X��0�]c^^S���T�i�����m8'Hk�4�@N�����5>N�5�v�@��~�o��}N�Ů��jz��vE��]ah�iT��X������CeZ���XP�ˣ�����
��<,;Y��p�Q�����rҖ��M�:э��ab`���M��
Ȩ[�(�=�aVfa����BeCi��DxPxgy;���`�������n�[��۶�r��0���<���KȔ\��W��0��	P��A�/�����g`��������n����۶�r��,	������=` �Ʌ�������_����_�T7c�Qwba�zri���As2����k�w��O�~�h�uoe�G��4��������P�E�Zyw����h�QR*�Ap����^��7mڢ��/�͈��x痨�A�F=�Y9m���"��7R�X��a��v vJ�#9 �)	��r z����7V�\�.��J��;��y*6��.8����Z;��w%Ed��%��j=6)�v��Y��D��s\A�&T����û��L.�?���/P�+��G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�}�V��L��������s��?��.���,���H&���Q�Q�Mf��j-k�4.���<��&;�`�V��pk/W+L^�J�vQ�Z��\�%�.,�Î�{�z����,�T-+��>t�E7�����%�?��D������q�������\�?�� ��?-������&Ƀ����������j�,jzGVEbNbb�h�������֢�S"7�n��?�/��p��� �0���Ǭ)�c�C�:b'dq��uz@�-�->��j�mY7��zDg�G�a��"k����ג���"��=����=��C�����/��B�A��A������r�l@4���c�"�����7>�����{p��{��E�r1��һ����O9 ����� �y!��9 ��m�U��7��-H.T+�Z��j���ҩ��r�Jͧ2�$��bV����'��Y�j�<�����0�H��TiVhm��j!���fv��DMH��';O|�V��LE�;��iL0���&&M��|�ZIItz��=l����C]-UI'�d��q48V�VD2���{�����қf9��+�e?5��J�ö�G{��p�HS��W���S�f+���G���J��ʞZ����n�0Fb��22�������Ѫ�7�3�;N�U���?�������I��[w5����볿��$����?�pE�?�ݹmzx������:���?����:U�}��1^Ğ"��j���0���Sg\��������зܕ�KOwN�l*���Dn����8����7�������>o��O~����y��z>����?�9ؿ<�q~3�c���J���N>�7����)�k�[�#�����}����)�����!t�#t-r0�xu�Ƹ��F1n���B׋qm�:=1k͛G�Xd����;}F5�7�ah�{���4b?<`�����s��_����f��Q�����ÞT�/��_���x���ox���W�Q�Ǐ����w�c���pz��o�w��Nħ���+|�'޷~v�w��u&Z�6���C`�+sn�!~~$�����t7�3���un�O�T�­繞��R�
?��?q7��&����Bo�~�4���������M�v���0�p|��_���+�L3�ͭ�ٝE��s=�����s0<0͐��C�z�?���?n�q��W|��$K�"������0c�p>6��ׄ�t���z�uJi�����O��.�Ťv���S���7��ݪ)�cGuq�$�mt������i�w�j���t���/��+;�������M�3                             |?�7�� � 