# TVM Wheels

This is a simple project wrapper for build TVM libraries as a python package.

The wheels are available on pypi.org at:
- xtc-tvm-python-bindings : TVM tools and python bindings

## Installing the TVM wheels for some project

The minimal required python version is: `python >= 3.10`

In a python environment setup for instance with:

    python3 -m venv .venv
    source .venv/bin/activate

One can install the tvm libraries `0.19.0.*` with for instance:

    pip3 install xtc-tvm-python-bindings~=0.19.0.0

Or on can add in a `tvm_requirements.txt` file for instance:

    xtc-tvm-python-bindings~=0.19.0.0

And run:

    pip3 install -r tvm_requirements.txt
    ...
    Successfully installed xtc-tvm-python-bindings-0.19.0.8

## Using tvm installed tools

From python, simply import tvm in `simple.py`:

    import tvm.version
    print(tvm.version.__version__)

And run:

    python simple.py
    0.19.0

The TVM compiler is also available as `tvmc`:

    tvmc --version
    0.19.0


## Maintenance

The following section if for the owners of the repository who maintain the published
packages.

### Publish new versions

Ensure that your current python version is 3.10.x, otherwise the installed packages
will not be available for this version.

Then install dependencies for the build script:

    pip install -r requirements.py

Update the version for TVM:
- in `tvm_revision.txt`: put the full sha1 of the new revision to publish
- in `version.txt`: update to `x.y.z.X`
  where `x.y.z` is the TVM last tag for this revision.
  The 'X' part is actually the part identifying the revision
  of the wheel, should start by 1 at each new TVM revision.

Then run the cibuildwheel which will create the wheels to install in `wheelhouse/`:

     ./checkout-tvm.sh
     ./build-wheels.sh

Once built, one may publish to some pypi repository with (here `test.pypi.org`):

    python -m twine upload -u '<user>' -p '<token>' \
    --repository-url https://test.pypi.org/legacy/ \
    wheelhouse/*.whl
