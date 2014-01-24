ALEMBIC BUILD AUTOMATION
========================

The provided scripts automatically compile everything (Alembic and all its dependencies),
installing to a single directory (`$TGT`).

Before launching the scripts, edit env-build-config.sh setting environment variables as desired.
The most influential are:

* `TGT`: the target directory where everything will be installed (default: `/opt/jcube`)
* `TARGET_64`: if the target is 64 bit (default: `yes`)
* `PYTHON_VERSION`: if using 2.6 or 2.7 (default: `2.6`)

Then create the target directory. For example:

	sudo mkdir -p /opt/jcube
	sudo chown $UID:$GID /opt/jcube

Then, simply run:

	./do-build-all.sh


CURRENT LIMITATIONS
-------------------

The whole thing has been tested only on Ubuntu 12.04.4 LTS x86_64

Perhaps some changes will be necessary if changing `TGT` to something else than `/opt/jcube`
(especially inside Python own `setup.py` for Berkeley DB lib search and inside Alembic
various `CMakeLists.txt` and `build/Find*.cmake` modules).

Only Python 2.6 has been tested.

The Python Alembic module gets compiled, but a couple of issues remain:

* the `alembic` module doesn't automatically load the `imath` module
* `imath` signatures do not match and throw errors

Regarding the first problem, it's necessary to load `imath` explicitly before `alembic`:

	$ . env-build-setup.sh
	$ type python
	python is /opt/jcube/bin/python

	$ python
	Python 2.6.8 (unknown, Jan 20 2014, 15:57:43)
	[GCC 4.6.3] on linux3
	Type "help", "copyright", "credits" or "license" for more information.
	>>> import alembic
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	AttributeError: 'NoneType' object has no attribute 'iex'

	$ python
	Python 2.6.8 (unknown, Jan 20 2014, 15:57:43)
	[GCC 4.6.3] on linux3
	Type "help", "copyright", "credits" or "license" for more information.
	>>> import imath
	>>> import alembic
	>>> dir(alembic)
	['Abc', 'AbcCollection', 'AbcCoreAbstract', 'AbcGeom', 'AbcMaterial', 'Util', '__doc__', '__file__', '__name__', '__package__', '__path__']
	>>> iarch = alembic.Abc.IArchive('Alembic_Octopus_Example/alembic_octopus.abc')
	>>> print "Reading", iarch.getName()
	Reading Alembic_Octopus_Example/alembic_octopus.abc
	>>> top = iarch.getTop()
	>>> top.getName()
	'ABC'

Regarding the second problem:

	$ cd Alembic_1.5.3_2013121700/python/PyAlembic/Tests/
	$ python testXform.py

	Running testXformBinding
	Traceback (most recent call last):
	  File "testXform.py", line 204, in <module>
	    test[1]()
	  File "testXform.py", line 192, in testXformBinding
	    xformOut()
	  File "testXform.py", line 77, in xformOut
	    asamp.addOp(transop, V3d(12.0, i+42.0, 20.0))
	Boost.Python.ArgumentError: Python argument types in
	    XformSample.addOp(XformSample, XformOp, V3d)
	did not match C++ signature:
	    addOp(Alembic::AbcGeom::v7::XformSample {lvalue}, Alembic::AbcGeom::v7::XformOp op)
	    addOp(Alembic::AbcGeom::v7::XformSample {lvalue}, Alembic::AbcGeom::v7::XformOp axisRotateOp, double degrees)
	    addOp(Alembic::AbcGeom::v7::XformSample {lvalue}, Alembic::AbcGeom::v7::XformOp matrixOp, Imath::Matrix44<double> matrix)
	    addOp(Alembic::AbcGeom::v7::XformSample {lvalue}, Alembic::AbcGeom::v7::XformOp rotateOp, Imath::Vec3<double> axis, double degrees)
	    addOp(Alembic::AbcGeom::v7::XformSample {lvalue}, Alembic::AbcGeom::v7::XformOp transOrScaleOp, Imath::Vec3<double> value)

Please see this [thread](https://groups.google.com/forum/?fromgroups=#!topic/alembic-discussion/7k5tQozZfTo) for others having the same problem.


REFERENCES
----------

* http://www.alembic.io/
* http://murphyrandle.apps.runkite.com/building-pyalembic/
* https://groups.google.com/forum/?fromgroups=#!topic/alembic-discussion/iqo1MKE4kyc
* https://groups.google.com/forum/?fromgroups=#!topic/alembic-discussion/7k5tQozZfTo
* http://stackoverflow.com/questions/19148564/getting-failed-to-build-these-modules-curses-curses-panel-ssl-while-install
