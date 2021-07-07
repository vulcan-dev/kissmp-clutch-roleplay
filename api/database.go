package main

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	_ "github.com/denisenkom/go-mssqldb"
	"github.com/sirupsen/logrus"
)

type SDatabase struct {
	Server   string
	User     string
	Password string
	Port     int
	Database *sql.DB
}

func (db *SDatabase) new() (int, error) {
	connFormat := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%d", db.Server, db.User, db.Password, db.Port)

	var err error
	db.Database, err = sql.Open("mssql", connFormat); if err != nil {
		return -1, err
	};
		
	if err := db.Database.Ping(); err != nil {
		return -1, err
	}
	
	log.WithFields(logrus.Fields{
		"User": db.User,
		"Port": db.Port,
		"Server": db.Server,
	}).Info("Connected to Database")

	return 0, nil
}

func (db *SDatabase) AddUser(secret string, name string, rank uint8) (int64, error) {
	if canUseDB {
		ctx := context.Background()
		if err := db.Database.PingContext(ctx); err != nil {
			return -1, err
		}

		sqlData := fmt.Sprintf(`
			INSERT INTO KissMP.dbo.Users (Secret, Name, Rank, Playtime) VALUES ('%s', '%s', %d, 0);
		`, secret, name, rank)

		stmt, err := db.Database.Prepare(sqlData); if err != nil {
			return -1, err
		}; defer stmt.Close()

		rows, err := db.Database.QueryContext(ctx, sqlData); if err != nil {
			return -1, err
		}; defer rows.Close()

		log.WithFields(logrus.Fields{
			"Secret": secret,
			"Name": name,
			"Rank": rank,
			"Playtime": 0,
		}).Infoln("[DB] Successfully created user")

		return 0, nil
	}

	return 0, fmt.Errorf("[DB] Unable to use Database. Make sure it's up")
}

func (db* SDatabase) AddBan(secret string, reason string, time float64, timeString string, unbanDate string) (int64, error) {
	if canUseDB {
		ctx := context.Background()
		if err := db.Database.PingContext(ctx); err != nil {
			return -1, err
		}

		sqlData := fmt.Sprintf(`
			INSERT INTO KissMP.dbo.Bans (Secret, Reason, Time, TimeString, UnbanDate) VALUES ('%s', '%s', %f, '%s', '%s');
		`, secret, reason, time, timeString, unbanDate)

		stmt, err := db.Database.Prepare(sqlData); if err != nil {
			return -1, err
		}; defer stmt.Close()
			
		rows, err := db.Database.QueryContext(ctx, sqlData); if err != nil {
			if strings.Contains(err.Error(), "duplicate") {
				db.UpdateTable("Bans", secret, "Reason", fmt.Sprintf("'%s'", reason))
				db.UpdateTable("Bans", secret, "Time", time)
				db.UpdateTable("Bans", secret, "TimeString", fmt.Sprintf("'%s'", timeString))
				db.UpdateTable("Bans", secret, "UnbanDate", fmt.Sprintf("'%s'", unbanDate))
				return 0, nil
			} else {
				return -1, err
			}
		}; defer rows.Close()

		log.WithFields(logrus.Fields{
			"Secret": secret,
			"Reason": reason,
			"Time": time,
			"TimeString": timeString,
			"Unban Date": unbanDate,
		}).Infoln("[DB] Successfully banned user")

		return 0, nil
	}

	return 0, fmt.Errorf("[DB] Unable to use Database. Make sure it's up")
}

func (db *SDatabase) GetTable(table string, secret string) (interface{}, error) {
	if canUseDB {
		ctx := context.Background()

		if err := db.Database.PingContext(ctx); err != nil {
			return -1, err
		}

		tsql := fmt.Sprintf(`SELECT * FROM KissMP.dbo.%s WHERE KissMP.dbo.%s.Secret = N'%s'`, table, table, secret)
		rows, err := db.Database.QueryContext(ctx, tsql); if err != nil {
			return -1, err
		}; defer rows.Close()

		var count int64
		for rows.Next() {
			var name, secret string
			var rank, playtime int64

			if err := rows.Scan(&secret, &name, &rank, &playtime); err != nil {
				return -1, err
			}

			log.WithFields(logrus.Fields{
				"Secret": secret,
				"Name": name,
				"Rank": rank,
				"Playtime": playtime,
			}).Infoln("[DB] Successfully got user")
			count++
		}

		return 0, nil
	}

	return 0, fmt.Errorf("[DB] Unable to use Database. Make sure it's up")
}

func (db* SDatabase) UpdateTable(table string, secret string, key string, value interface{}) (int64, error) {
	if canUseDB {
		ctx := context.Background()

		if err := db.Database.PingContext(ctx); err != nil {
			return -1, err
		}

		tsql := fmt.Sprintf("UPDATE KissMP.dbo.%s SET %s = %v WHERE Secret = '%s'", table, key, value, secret)

		res, err := db.Database.ExecContext(ctx, tsql); if err != nil {
			return -1, err
		}

		log.Infoln("[DB] Successfully updated user")

		return res.RowsAffected()
	}

	return 0, fmt.Errorf("[DB] Unable to use Database. Make sure it's up")
}

func (db* SDatabase) GetField(table string, secret string, key string) (int64, error) {
	if canUseDB {
		ctx := context.Background()

		if err := db.Database.PingContext(ctx); err != nil {
			return -1, err
		}

		var value interface{}
		tsql := fmt.Sprintf("SELECT %s FROM KissMP.dbo.%s WHERE KissMP.dbo.%s.Secret = N'%s';", key, table, table, secret)

		err := db.Database.QueryRowContext(ctx, tsql).Scan(&value); if err != nil {
			return -1, err
		}

		log.Infoln(value)
		return 0, nil
	}

	return 0, fmt.Errorf("[DB] Unable to use Database. Make sure it's up")
}

func (db* SDatabase) DeleteTable(table string, secret string) (int64, error) {
	if canUseDB {
		ctx := context.Background()

		if err := db.Database.PingContext(ctx); err != nil {
			return -1, err
		}

		tsql := fmt.Sprintf("DELETE FROM KissMP.dbo.%s WHERE Secret = '%s'", table, secret)
		res, err := db.Database.ExecContext(ctx, tsql); if err != nil {
			return -1, err
		}

		log.Infoln("[DB] Successfully removed user")

		return res.RowsAffected()
	}

	return 0, fmt.Errorf("[DB] Unable to use Database. Make sure it's up")
}