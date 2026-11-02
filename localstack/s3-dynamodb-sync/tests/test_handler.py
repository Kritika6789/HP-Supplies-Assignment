import io
import unittest

from unittest.mock import MagicMock
from terraform.function.handler import csv_rows, sync_csv


class CsvRowsTests(unittest.TestCase):
    def test_converts_rows_to_items_with_source_and_row_keys(self):
        rows = list(csv_rows(io.BytesIO(b"id,name\n1,Ada\n2,Linus\n"), "people.csv"))

        self.assertEqual(
            rows,
            [
                {"source_key": "people.csv", "row_number": 1, "id": "1", "name": "Ada"},
                {"source_key": "people.csv", "row_number": 2, "id": "2", "name": "Linus"},
            ],
        )

    def test_header_only_file_has_no_rows(self):
        self.assertEqual(
            list(csv_rows(io.BytesIO(b"id,name\n"), "empty.csv")),
            [],
        )

    def test_rejects_duplicate_headers(self):
        with self.assertRaisesRegex(ValueError, "duplicate"):
            list(csv_rows(io.BytesIO(b"id,id\n1,2\n"), "duplicate.csv"))

    def test_rejects_reserved_headers(self):
        with self.assertRaisesRegex(ValueError, "reserved"):
            list(csv_rows(io.BytesIO(b"source_key,name\nfile.csv,Ada\n"), "file.csv"))

    def test_sync_csv_skips_empty_csv_file(self):
        s3 = MagicMock()
        s3.get_object.return_value = {"Body": io.BytesIO(b"")}
        table = MagicMock()

        sync_csv(s3, table, "my-bucket", "empty.csv")

        table.batch_writer.assert_not_called()
        table.query.assert_not_called()

    def test_sync_csv_skips_header_only_csv_file(self):
        s3 = MagicMock()
        s3.get_object.return_value = {"Body": io.BytesIO(b"id,name\n")}
        table = MagicMock()

        sync_csv(s3, table, "my-bucket", "header_only.csv")

        table.batch_writer.assert_not_called()
        table.query.assert_not_called()


if __name__ == "__main__":
    unittest.main()
