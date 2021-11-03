from django.db import models


class ReplicationTestRecord(models.Model):
    test_text = models.CharField(max_length=200)
    change_date = models.DateTimeField('date updated')

    def __str__(self):
        return self.test_text