import numpy as np


def BorderSpan(Border_coordinates=None, *args, **kwargs):
    coordinates = np.copy(Border_coordinates)

    coordinates_sorted = coordinates[np.argsort(coordinates[:, 1])]

    minx = coordinates_sorted(1, 1)

    maxx = coordinates_sorted(len(coordinates_sorted), 1)

    coordinates_sorted = coordinates[np.argsort(coordinates[:, 2])]

    miny = coordinates_sorted(1, 2)

    maxy = coordinates_sorted(len(coordinates_sorted), 2)

    return minx, maxx, miny, maxy


if __name__ == '__main__':
    pass