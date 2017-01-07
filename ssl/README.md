<p align="center">
  <a href="http://thorpora.fr">
    <img src="http://thorpora.fr/wp-content/uploads/2015/03/thorpora4.4.png" width="300" alt="Thorpora - Synology free certificate">
  </a>
</p>

This is a simple script to renew the Let's Encrypt free certificate.
It has been originaly created for a NAS Synology plateform.
It can be automated with a simple cron :

<pre>
 0  0   */30    *   *   root    YOUR_PATH/renewFreeCertificate.sh
</pre>


Please visit [this article](http://thorpora.fr/synology-certificat-valide-avec-lets-encrypt/) for more informations (french)
