# Disk Speed Test Script

A Bash script to perform a disk speed check on a specified path. This script measures both write and read speeds by creating and reading a temporary file of a specified size.

## Instant Installation & Usage Defaults 

This single line will acquire the `disk-speed.sh` script and execute it in the current directory of your terminal with a 100MB file sample size and `--no-sudo` options.

```sh
sh <(curl -sL https://raw.githubusercontent.com/andreimerlescu/disk-speed/main/disk-speed.sh) --path . --size 100M --no-sudo
```

## Usage

```sh
./disk-speed.sh --path /path/to/directory --size 10G [--sudo] [--debug]
```

### Options

- `--path`: Path of the directory to read/write from. (Required)
- `--size`: Size of the temp file to write and read from to measure performance. Units are:
  - `10` for bytes
  - `10K` for kilobytes
  - `10M` for megabytes
  - `10G` for gigabytes
  - `10T` for terabytes (Required)
- `--sudo`: Run the script with sudo.
- `--no-sudo`: Run the script without sudo. (Default)
- `--debug`: Enable debug mode to print executed commands.
- `--help`: Show the help menu.

### Example

```sh
./disk-speed.sh --path /database --size 10G --sudo
```

This command will check the disk speed on the `/database` path using a 10GB file, with sudo privileges.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
