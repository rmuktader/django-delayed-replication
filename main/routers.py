class PrimaryReplicaRouter:
    """
    An example primary/replica router adapted from:
    https://docs.djangoproject.com/en/3.1/topics/db/multi-db/
    """

    db_set = {'default', 'replica'}
    # set of table names that should always use the default/writer DB
    default_only = {
        'auth_user',
        'core_profile',
        'content_access_siteuser',
        'constance_config',
    }

    def db_for_read(self, model, **hints):
        """
        Reads go to the replica.
        """
        tbl = model._meta.db_table

        if tbl not in self.default_only:
            return 'replica'
        return 'default'

    def db_for_write(self, model, **hints):
        """
        Writes always go to primary.
        """
        return 'default'

    def allow_relation(self, obj1, obj2, **hints):
        """
        Relations between objects are allowed if both objects are
        in the primary/replica pool.
        """
        if obj1._state.db in self.db_set and obj2._state.db in self.db_set:
            return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        return True
