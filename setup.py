""" setup.py

    Basic setup file to enable pip install

    http://python-distribute.org/distribute_setup.py

    python setup.py register -r jive sdist upload -r jive

    
"""

from setuptools import setup, find_packages

setup(
    name = 'demoing',
    version = '0.0.1',
    description = 'OpenWest Demo Application',
    url = 'https://github.com/SmithSamuelM/openwestdemo.git',
    packages = find_packages(exclude=[]),
    package_data={'': ['*.txt',  '*.ico',  '*.json', '*.md', '*.conf', ''
                       '*.js', '*.html', '*.css', '*.png', 'libs/*.txt',
                       'libs/angular/*.txt',
                       'libs/angular/*.js', 'libs/angular/i18n/*.js',
                       'libs/angular-gold/*.js', 'libs/bootstrap/css/*.css',
                       'libs/bootstrap/img/*.png', 'libs/bootstrap/js/*.js',]},
    install_requires = ['bottle', 'simplejson', 'gevent', 'brining', ],
    extras_require = { },
    tests_require = ['webtest', 'nose'],
    test_suite = 'nose.collector',
    author='Samuel M Smith',
    author_email='smith.samuel.m@gmail.com',
    license="MIT",
    keywords='AngularJS BottlePY NoSQL',
)
