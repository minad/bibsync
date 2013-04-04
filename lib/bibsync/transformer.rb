module BibSync
  class Transformer
    include Utils

    def call(bib)
      bib.each do |entry|
        next if entry.comment?

        if entry[:author]
          entry[:author] = entry[:author].gsub(/\{(\w+)\}/, '\\1').gsub(/#/, ' and ')
        end

        if entry[:doi] && entry[:doi] =~ /(PhysRev|RevModPhys).*?\.(\d+)$/
          entry[:publisher] ||= 'American Physical Society'
          entry[:pages] ||= $2
        end

        if entry[:publisher] && entry[:publisher] =~ /American Physical Society/i
          entry[:publisher] = 'American Physical Society'
        end

        if entry[:month]
          entry[:month] = Bibliography::RawValue.new(entry[:month].downcase)
        end

        if entry[:journal]
          if entry[:journal] =~ /EPL/
            entry[:year] = $1 if entry[:journal] =~ /\((\d{4})\)/
            entry[:pages] = $1 if entry[:journal] =~ / (\d{5,10})( |\Z)/
            entry[:volume] = $1 if entry[:journal] =~ / (\d{2,4})( |\Z)/
            entry[:journal] = 'Europhysics Letters'
          end

          if entry[:journal] =~ /(Phys\.|Physical) (Rev\.|Review) Lett[^ ]+ /
            entry[:year] = $1 if entry[:journal] =~ /\((\d{4})\)/
            entry[:pages] = $1 if entry[:journal] =~ / (\d{5,10})( |,|\Z)/
            entry[:volume] = $1 if entry[:journal] =~ / (\d{2,4})( |,|\Z)/
            entry[:journal] = 'Physical Review Letters'
          end

          if entry[:journal] =~ /(Phys\.|Physical) (Rev\.|Review) (\w) /
            letter = $3
            entry[:year] = $1 if entry[:journal] =~ /\((\d{4})\)/
            entry[:pages] = $1 if entry[:journal] =~ / (\d{5,10})( |,|\Z)/
            entry[:volume] = $1 if entry[:journal] =~ / (\d{2,4})( |,|\Z)/
            entry[:journal] = "Physical Review #{letter}"
          end

          case entry[:journal]
          when /\APhysical Review (\w)\Z/i
            entry[:shortjournal] = "PR#{$1.upcase}"
          when /\APhysical Review Letters\Z/i
            entry[:shortjournal] = 'PRL'
          when /\AReviews of Modern Physics\Z/i
            entry[:shortjournal] = 'RMP'
          when /\ANew Journal of Physics\Z/i
            entry[:shortjournal] = 'NJP'
          when /\A#{ArXivJournal}\Z/i
            entry[:shortjournal] = 'arXiv'
          when /\AEurophysics Letters\Z/i
            entry[:shortjournal] = 'EPL'
          else
            entry[:shortjournal] = entry[:journal]
          end
        end
      end
    end
  end
end
