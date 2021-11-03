from django.http import HttpResponse
from django.utils import timezone
from .models import ReplicationTestRecord
from django.db import connections

def index(request):
    now = timezone.now()
    rec, _ = ReplicationTestRecord.objects.get_or_create(id=1, defaults={'change_date': now,'test_text': now})
    rec.test_text = now
    rec.change_date = now
    rec.save()

    try:
        read = ReplicationTestRecord.objects.get(id=1)
        read_ts = read.test_text
    except ReplicationTestRecord.DoesNotExist:
        read_ts = 'Unknown'

    return HttpResponse(f"Write TS: {now}, Read TS: {read_ts}")