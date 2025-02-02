# TVM Wheels

This is a simple project wrapper for build TVM libraries as a python package.

The actual gitlab wheels can then be viewd from: https://gitlab.inria.fr/groups/CORSE/-/packages

## Installing the TVM wheels for some project

The minimal required python version is: `python >= 3.10`

In a python environment setup for instance with:

    python3 -m venv .venv
    source .venv/bin/activate

One can install the tvm libraries `0.16.*` with for instance:

    pip3 install tvm~=0.16.0 \
    -i https://gitlab.inria.fr/api/v4/projects/57616/packages/pypi/simple

Or on can add in a `tvm_requirements.txt` file for instance:

    --index-url https://gitlab.inria.fr/api/v4/projects/57616/packages/pypi/simple
    tvm~=0.16.0

And run:

    pip3 install -r tvm_requirements.txt
    ...
    Successfully installed tvm-0.16.0.2024041301+64969035

## Using tvm installed tools

From python, simply import tvm in `simple.py`:

    import tvm.version
    print(tvm.version.__version__)

And run:

    python simple.py
    0.16.0

The TVM compiler is also available as `tvmc`:

    tvmc --version
    0.16.0


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
- in `tvm_version.txt`: update to `x.y.z.YYYMMDDHH+<sha1[:8]>`
  where `sha1[:8]` is the first 8 bytes of the revision above, and `x.y.z` is the
  TVM last tag for this revision.

Then run the cibuildwheel which will create the wheels to install in `wheelhouse/`:

     ./checkout-tvm.sh
     ./build-wheels.sh

Once built, one may publish to the project repository with:

    python -m twine upload -u '<user>' -p '<token>' \
    --repository-url https://gitlab.inria.fr/api/v4/projects/57616/packages/pypi \
    wheelhouse/*.whl
