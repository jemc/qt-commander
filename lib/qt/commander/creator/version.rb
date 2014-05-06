
module Qt::Commander::Creator
  class Version < InfoObject
    
    key :id,              'Id'
    key :name,            'Name'
    key :qmake,           'QMakePath'
    key :type,            'QtVersion.Type'
    key :autodetected,    'isAutodetected'
    key :autodetect_src,  'autodetectionSource', optional:true
    
  end
end
