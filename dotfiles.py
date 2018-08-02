import sys
import os
from subprocess import call


class color:
    @classmethod
    def blue(cls, string):
        return "\033[00;34m%s\033[0m" % string

    @classmethod
    def yellow(cls, string):
        return "\033[00;33m%s\033[0m" % string

    @classmethod
    def green(cls, string):
        return "\033[00;32m%s\033[0m" % string

    @classmethod
    def red(cls, string):
        return "\033[00;31m%s\033[0m" % string


class log:
    @classmethod
    def info(cls, text):
        print("  [ %s ] %s" % (color.blue(".."), text))

    @classmethod
    def user(cls, text):
        print("\r  [ %s ] %s" % (color.yellow("??"), text))

    @classmethod
    def success(cls, text):
        print("\r\033[2K  [ %s ] %s" % (color.green("OK"), text))

    @classmethod
    def fail(cls, text):
        print("\r\033[2K  [%s] %s" % (color.red("FAIL"), text))
        sys.exit(1)

    @classmethod
    def log(cls, text):
        print("         %s" % text)


class Recipe(object):

    links = ()

    def link(self):
        """ Symlink specified files """
        for source, target in self.links:
            self.symlink(source, target)

    def unlink(self):
        """ Remove symlinks """
        for source, target in self.links:
            self.unlink(target)

    def symlink(self, source, target, verbose=False):
        """ Symlink source to target """
        # return run(["ln","-s",source, target], verbose)
        try:
            if (verbose):
                log.log("ln -s %s %s" % (source, target))
            os.symlink(source, target)
            return True
        except OSError as e:
            log.fail(e.strerror)

    def remove_link(self, target, verbose=True):
        try:
            if os.path.islink(target):
                if (verbose):
                    log.log("rm %s" % target)
                os.remove(target)
            else:
                log.fail("The target is not a symlink: %s" % target)
        except OSError as e:
            log.fail(e.strerror)

    def run(command, shell=True, verbose=True):
        """ Run a command and return the return code """
        if type(command) is not list:
            command = [command]

        result = call(command, shell)

        if(verbose):
            log.log(' '.join(command))

        return result


if __name__ == "__main__":
    log.info("Script started")
    log.user("User input")
    log.success("Success!!!")
    log.fail("Fail :(")
