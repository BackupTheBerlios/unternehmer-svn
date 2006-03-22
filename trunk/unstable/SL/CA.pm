#=====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#
#=====================================================================
# SQL-Ledger Accounting
# Copyright (C) 2001
#
#  Author: Dieter Simader
#   Email: dsimader@sql-ledger.org
#     Web: http://www.sql-ledger.org
#
#  Contributors:
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#======================================================================
# chart of accounts
#
# CHANGE LOG:
#   DS. 2000-07-04  Created
#
#======================================================================


package CA;


sub all_accounts {
  my ($self, $myconfig, $form) = @_;

  my $amount = ();
  # connect to database
  my $dbh = $form->dbconnect($myconfig);

  my $query = qq|SELECT c.accno,
                 SUM(a.amount) AS amount
                 FROM chart c, acc_trans a
		 WHERE c.id = a.chart_id
		 GROUP BY c.accno|;
  my $sth = $dbh->prepare($query);
  $sth->execute || $form->dberror($query);

  while (my $ref = $sth->fetchrow_hashref(NAME_lc)) {
    $amount{$ref->{accno}} = $ref->{amount}
  }
  $sth->finish;
 
  $query = qq|SELECT accno, description
              FROM gifi|;
  $sth = $dbh->prepare($query);
  $sth->execute || $form->dberror($query);

  my $gifi = ();
  while (my ($accno, $description) = $sth->fetchrow_array) {
    $gifi{$accno} = $description;
  }
  $sth->finish;

  $query = qq|SELECT c.id, c.accno, c.description, c.charttype, c.gifi_accno,
              c.category, c.link
              FROM chart c
	      ORDER BY accno|;
  $sth = $dbh->prepare($query);
  $sth->execute || $form->dberror($query);
 
  while (my $ca = $sth->fetchrow_hashref(NAME_lc)) {
    $ca->{amount} = $amount{$ca->{accno}};
    $ca->{gifi_description} = $gifi{$ca->{gifi_accno}};
    if ($ca->{amount} < 0) {
      $ca->{debit} = $ca->{amount} * -1;
    } else {
      $ca->{credit} = $ca->{amount};
    }
    push @{ $form->{CA} }, $ca;
  }

  $sth->finish;
  $dbh->disconnect;

}


sub all_transactions {
  my ($self, $myconfig, $form) = @_;

  # connect to database
  my $dbh = $form->dbconnect($myconfig);

  # get chart_id
  my $query = qq|SELECT c.id FROM chart c
                 WHERE c.accno = '$form->{accno}'|;
  if ($form->{accounttype} eq 'gifi') {
    $query = qq|SELECT c.id FROM chart c
                WHERE c.gifi_accno = '$form->{gifi_accno}'|;
  }
  my $sth = $dbh->prepare($query);
  $sth->execute || $form->dberror($query);

  my @id = ();
  while (my ($id) = $sth->fetchrow_array) {
    push @id, $id;
  }
  $sth->finish;

  my $fromdate_where;
  my $todate_where;
  
  if ($form->{fromdate}) {
    $fromdate_where = qq|
                 AND ac.transdate >= '$form->{fromdate}'
		|;
  }
  if ($form->{todate}) {
    $todate_where .= qq|
                 AND ac.transdate <= '$form->{todate}'
		|;
  }
  

  my $sortorder = join ', ', $form->sort_columns(qw(transdate reference description));
  my $false = ($myconfig->{dbdriver} eq 'Pg') ? FALSE : q|'0'|;
  
  # Oracle workaround, use ordinal positions
  my %ordinal = ( transdate => 4,
		  reference => 2,
		  description => 3 );
  map { $sortorder =~ s/$_/$ordinal{$_}/ } keys %ordinal;


  my ($null, $department_id) = split /--/, $form->{department};
  my $dpt_where;
  my $dpt_join;
  if ($department_id) {
    $dpt_join = qq|
                   JOIN department t ON (t.trans_id = ac.trans_id)
		  |;
    $dpt_where == qq|
		   AND t.department_id = $department_id
		  |;
  }

  my $project;
  if ($form->{project_id}) {
    $project = qq|
                 AND ac.project_id = $form->{project_id}
		 |;
  }

  if ($form->{accno} || $form->{gifi_accno}) {
    # get category for account
    $query = qq|SELECT c.category
                FROM chart c
		WHERE c.accno = '$form->{accno}'|;

    if ($form->{accounttype} eq 'gifi') {
      $query = qq|SELECT c.category
                FROM chart c
		WHERE c.gifi_accno = '$form->{gifi_accno}'
		AND c.charttype = 'A'|;
    }

    $sth = $dbh->prepare($query);

    $sth->execute || $form->dberror($query);
    ($form->{category}) = $sth->fetchrow_array;
    $sth->finish;
    
    if ($form->{fromdate}) {

      # get beginning balance
      $query = qq|SELECT SUM(ac.amount)
		  FROM acc_trans ac
		  JOIN chart c ON (ac.chart_id = c.id)
		  $dpt_join
		  WHERE c.accno = '$form->{accno}'
		  AND ac.transdate < '$form->{fromdate}'
		  $dpt_where
		  $project
		  |;

      if ($form->{project_id}) {

	$query .= qq|

	       UNION

	          SELECT SUM(ac.sellprice)
		  FROM invoice ac
		  JOIN ar a ON (ac.trans_id = a.id)
		  JOIN parts p ON (ac.parts_id = p.id)
		  JOIN chart c ON (p.income_accno_id = c.id)
		  $dpt_join
		  WHERE c.accno = '$form->{accno}'
		  AND a.transdate < '$form->{fromdate}'
		  AND c.category = 'I'
		  $dpt_where
		  $project

	       UNION

	          SELECT SUM(ac.sellprice)
		  FROM invoice ac
		  JOIN ap a ON (ac.trans_id = a.id)
		  JOIN parts p ON (ac.parts_id = p.id)
		  JOIN chart c ON (p.expense_accno_id = c.id)
		  $dpt_join
		  WHERE c.accno = '$form->{accno}'
		  AND a.transdate < '$form->{fromdate}'
		  AND c.category = 'E'
		  $dpt_where
		  $project
		  |;

      }

      if ($form->{accounttype} eq 'gifi') {
        $query = qq|SELECT SUM(ac.amount)
		  FROM acc_trans ac
		  JOIN chart c ON (ac.chart_id = c.id)
		  $dpt_join
		  WHERE c.gifi_accno = '$form->{gifi_accno}'
		  AND ac.transdate < '$form->{fromdate}'
		  $dpt_where
		  $project
		  |;
		  
	if ($form->{project_id}) {

	  $query .= qq|

	       UNION

	          SELECT SUM(ac.sellprice)
		  FROM invoice ac
		  JOIN ar a ON (ac.trans_id = a.id)
		  JOIN parts p ON (ac.parts_id = p.id)
		  JOIN chart c ON (p.income_accno_id = c.id)
		  $dpt_join
		  WHERE c.gifi_accno = '$form->{gifi_accno}'
		  AND a.transdate < '$form->{fromdate}'
		  AND c.category = 'I'
		  $dpt_where
		  $project

	       UNION

	          SELECT SUM(ac.sellprice)
		  FROM invoice ac
		  JOIN ap a ON (ac.trans_id = a.id)
		  JOIN parts p ON (ac.parts_id = p.id)
		  JOIN chart c ON (p.expense_accno_id = c.id)
		  $dpt_join
		  WHERE c.gifi_accno = '$form->{gifi_accno}'
		  AND a.transdate < '$form->{fromdate}'
		  AND c.category = 'E'
		  $dpt_where
		  $project
		  |;

	}
      }
      
      $sth = $dbh->prepare($query);

      $sth->execute || $form->dberror($query);
      ($form->{balance}) = $sth->fetchrow_array;
      $sth->finish;
    }
  }

  $query = "";
  my $union = "";

  foreach my $id (@id) {
    
    # get all transactions
    $query .= qq|$union
                 SELECT g.id, g.reference, g.description, ac.transdate,
	         $false AS invoice, ac.amount, 'gl' as module
		 FROM gl g
		 JOIN acc_trans ac ON (ac.trans_id = g.id)
		 $dpt_join
		 WHERE ac.chart_id = $id
		 $fromdate_where
		 $todate_where
		 $dpt_where
		 $project
      
             UNION ALL
      
                 SELECT a.id, a.invnumber, c.name, ac.transdate,
	         a.invoice, ac.amount, 'ar' as module
		 FROM ar a
		 JOIN acc_trans ac ON (ac.trans_id = a.id)
		 JOIN customer c ON (a.customer_id = c.id)
		 $dpt_join
		 WHERE ac.chart_id = $id
		 $fromdate_where
		 $todate_where
		 $dpt_where
		 $project
      
             UNION ALL
      
                 SELECT a.id, a.invnumber, v.name, ac.transdate,
	         a.invoice, ac.amount, 'ap' as module
		 FROM ap a
		 JOIN acc_trans ac ON (ac.trans_id = a.id)
		 JOIN vendor v ON (a.vendor_id = v.id)
		 $dpt_join
		 WHERE ac.chart_id = $id
		 $fromdate_where
		 $todate_where
		 $dpt_where
		 $project
		 |;

    if ($form->{project_id}) {

      $fromdate_where =~ s/ac\./a\./;
      $todate_where =~ s/ac\./a\./;
      
      $query .= qq|

             UNION ALL
      
                 SELECT a.id, a.invnumber, c.name, a.transdate,
	         a.invoice, ac.sellprice, 'ar' as module
		 FROM ar a
		 JOIN invoice ac ON (ac.trans_id = a.id)
		 JOIN parts p ON (ac.parts_id = p.id)
		 JOIN customer c ON (a.customer_id = c.id)
		 $dpt_join
		 WHERE p.income_accno_id = $id
		 $fromdate_where
		 $todate_where
		 $dpt_where
		 $project
      
             UNION ALL
      
                 SELECT a.id, a.invnumber, v.name, a.transdate,
	         a.invoice, ac.sellprice, 'ap' as module
		 FROM ap a
		 JOIN invoice ac ON (ac.trans_id = a.id)
		 JOIN parts p ON (ac.parts_id = p.id)
		 JOIN vendor v ON (a.vendor_id = v.id)
		 $dpt_join
		 WHERE p.expense_accno_id = $id
		 $fromdate_where
		 $todate_where
		 $dpt_where
		 $project
		 |;
		 
      $fromdate_where =~ s/a\./ac\./;
      $todate_where =~ s/a\./ac\./;
 
    }
		 
      $union = qq|
             UNION ALL
                 |;
  }

  $query .= qq|
      ORDER BY $sortorder|;

  $sth = $dbh->prepare($query);
  $sth->execute || $form->dberror($query);

  while (my $ca = $sth->fetchrow_hashref(NAME_lc)) {
    
    # gl
    if ($ca->{module} eq "gl") {
      $ca->{module} = "gl";
    }

    # ap
    if ($ca->{module} eq "ap") {
      $ca->{module} = ($ca->{invoice}) ? 'ir' : 'ap';
    }

    # ar
    if ($ca->{module} eq "ar") {
      $ca->{module} = ($ca->{invoice}) ? 'is' : 'ar';
    }

    if ($ca->{amount} < 0) {
      $ca->{debit} = $ca->{amount} * -1;
      $ca->{credit} = 0;
    } else {
      $ca->{credit} = $ca->{amount};
      $ca->{debit} = 0;
    }

    push @{ $form->{CA} }, $ca;
    
  }
 
  $sth->finish;
  $dbh->disconnect;

}

1;

